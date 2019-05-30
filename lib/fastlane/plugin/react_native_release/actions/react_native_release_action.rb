require 'fastlane/action'
require_relative '../helper/react_native_release_helper'

module Fastlane
  module Actions
    class ReactNativeReleaseAction < Action
      VALID_TARGETS = %w{beta production}

      def self.run(params)
        require 'fastlane/plugin/android_versioning'
        
        if UI.select("Generate a fastlane session token? (The session token is used to authenticate with the App Store to upload iOS releases.)", ["yes", "no"]) === 'yes'
          create_fastlane_session
        end

        target = UI.select "Select a release type:", VALID_TARGETS
        is_beta = target.include?('beta')
        is_hotfix = params[:hotfix] === true
        ios_version = other_action.get_version_number(xcodeproj: params[:xcodeproj], target: File.basename(params[:xcodeproj], '.*'))
        android_version = other_action.get_version_name(app_project_dir: params[:android_app_dir])
        should_prompt_for_version_bump = params[:prompt_for_version_bump] === true || is_beta

        if is_beta
          tag_prefix = 'betas'
          base_branch = params[:alpha_branch]
          target_branch = params[:beta_branch]
        else
          tag_prefix = 'releases'
          base_branch = params[:beta_branch]
          target_branch = params[:production_branch]
        end

        # Ensure we're on the right branch and in a good state
        other_action.ensure_git_branch(branch: base_branch)
        other_action.ensure_git_status_clean
        sh "git branch --set-upstream-to=origin/#{base_branch} #{base_branch}"
        other_action.git_pull

        # Cut a fresh branch unless this is a hotfix
        if !is_hotfix
          # delete an existing branch if we have one
          sh "git show-ref #{target_branch}" do |status|
            sh "git branch -D #{target_branch}" if status.success?
          end
          
          sh "git checkout -b #{target_branch}"
        end

        # Tag / Bump version
        if should_prompt_for_version_bump
          version = prompt_for_version
          ios_version = bump_ios_version(version: version, xcodeproj: params[:xcodeproj])
          android_version = bump_android_version(version: version)

          if ios_version &&  android_version
            UI.message "Committing iOS v#{ios_version} and Android v#{android_version} to git"
            other_action.git_commit(
              path: ["#{Dir.pwd}/ios", "#{Dir.pwd}/android"],
              message: "Release iOS v#{ios_version} and Android v#{android_version}"
            )
          else
            UI.message "No version bump specified"
          end
        end

        # Tag it
        tag_name = "#{tag_prefix}/ios-#{ios_version}-android-#{android_version}"
        other_action.add_git_tag(tag: tag_name)
        other_action.push_to_git_remote(
          local_branch: target_branch,
          force: true
        )

        merge_branch(branch: target_branch, target: base_branch)
        return if is_beta

        # production releases need an additional merge back to the alpha branch
        merge_branch(branch: params[:beta_branch], target: params[:alpha_branch])
      end

      # Handles merging the specified branch into a target.
      # example: beta -> master
      def self.merge_branch(options)
        branch = options[:branch]
        target = options[:target]
      
        sh "git checkout #{target}"
        sh "git merge origin/#{branch} --no-ff -m 'Merge #{branch} -> #{target} [skip ci]' " do |status|
          unless status.success?
            UI.error "Failed to merge #{branch} into #{target}"
          end
          
          other_action.push_to_git_remote(
            local_branch: target  
          )
        end
      end

      def self.bump_ios_version(options)
        version_bump = options[:version] || prompt_for_version
        return if version_bump == "none"
      
        UI.message "bumping ios #{options[:xcodeproj]} to #{version_bump}"
        other_action.increment_version_number(
          xcodeproj: options[:xcodeproj],
          bump_type: version_bump
        )
      end
      
      def self.bump_android_version(options)
        version_bump = options[:version] || prompt_for_version
        return if version_bump == "none"
      
        UI.message "bumping android to #{version_bump}"
        other_action.increment_version_name(
          # TODO: make param
          app_project_dir: "#{Dir.pwd}/android/app",
          bump_type: version_bump
        )
      end
      
      def self.prompt_for_version
        UI.select("Update Version?: ", ["none", "major", "minor", "patch"])
      end

      # 
      def self.create_fastlane_session()
        require 'fastlane/plugin/cryptex'

        UI.message "Generating a new FASTLANE_SESSION."

        file = Tempfile.new('')

        fastlane_session_git_url =  ENV["FASTLANE_ENV_GIT_URL"]
        fastlane_session_username = ENV["FASTLANE_ENV_USERNAME"]

        if !fastlane_session_username;
          UI.user_error!("No FASTLANE_ENV_USERNAME var at <root>/fastlane/.env\nFASTLANE_ENV_USERNAME is used to authenticate with the App Store for iOS releases.")
        elsif !fastlane_session_git_url;
          UI.user_error!("No FASTLANE_ENV_GIT_URL var at <root>/fastlane/.env\nFASTLANE_ENV_GIT_URL is used to store the App Store Connect session to upload releases on CI.")
        else          
          system "yes | fastlane spaceauth -u #{fastlane_session_username}"
          system "pbpaste > #{file.path}"

          UI.message "File created at: #{file.path}"
        
          other_action.cryptex(
            type: "import",
            in: file.path,
            key: "FASTLANE_SESSION",
            git_url: fastlane_session_git_url
          )

          UI.message "Uploaded FASTLANE_SESSION securely to git repository."
        end
      end

      def self.description
        "Simplify releases for React Native apps"
      end

      def self.authors
        ["cball"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "Creates a release for a React Native app. Handles incrementing versions and tags"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :xcodeproj,
                                  env_name: "REACT_NATIVE_RELEASE_XCODE_PROJECT",
                               description: "Path to Xcode project",
                                  optional: true,
                                      type: String,
                             default_value: "#{Dir.pwd}/#{Dir['**/*.xcodeproj'].sort.first}",
                              verify_block: lambda do |value|
                                              UI.user_error!("Could not find Xcode project") unless File.exist?(value)
                                            end),
          FastlaneCore::ConfigItem.new(key: :android_app_dir,
                                  env_name: "REACT_NATIVE_RELEASE_ANDROID_APP_DIR",
                               description: "Path to Android app dir",
                                  optional: true,
                                      type: String,
                             default_value: "#{Dir.pwd}/android/app",
                              verify_block: lambda do |value|
                                              UI.user_error!("Could not find specified Android app dir") unless File.exist?(value)
                                            end),
          FastlaneCore::ConfigItem.new(key: :alpha_branch,
                                  env_name: "REACT_NATIVE_RELEASE_ALPHA_BRANCH",
                               description: "The branch used for alpha releases",
                                  optional: true,
                                      type: String,
                             default_value: 'master'),
          FastlaneCore::ConfigItem.new(key: :beta_branch,
                                  env_name: "REACT_NATIVE_RELEASE_BETA_BRANCH",
                               description: "The branch used for beta releases",
                                  optional: true,
                                      type: String,
                             default_value: 'beta'),
          FastlaneCore::ConfigItem.new(key: :production_branch,
                                  env_name: "REACT_NATIVE_RELEASE_PRODUCTION_BRANCH",
                               description: "The branch used for production releases",
                                  optional: true,
                                      type: String,
                             default_value: 'production'),
          FastlaneCore::ConfigItem.new(key: :target,
                                  env_name: "REACT_NATIVE_RELEASE_TARGET",
                               description: "The release target. Valid targets are #{VALID_TARGETS.join(', ')}",
                                  optional: true,
                                      type: String,
                              verify_block: lambda do |value|
                                              unless VALID_TARGETS.find{|v| value == v}
                                                UI.user_error!("Invalid target #{value}. Valid targets are #{VALID_TARGETS.join(', ')}") 
                                                next
                                              end
                                            end), 
          FastlaneCore::ConfigItem.new(key: :hotfix,
                                  env_name: "REACT_NATIVE_RELEASE_HOTFIX",
                               description: "If this is a hotfix. Will only pull the latest branch and tag",
                                  optional: true,
                                      type: Boolean,
                             default_value: false),
          FastlaneCore::ConfigItem.new(key: :prompt_for_version_bump,
                                  env_name: "REACT_NATIVE_RELEASE_PROMPT_FOR_VERSION_BUMP",
                               description: "Force the prompt to bump the app version. Otherwise, only prompts on beta",
                                  optional: true,
                                      type: Boolean,
                             default_value: false),
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        [:ios, :android].include?(platform)
      end
    end
  end
end
