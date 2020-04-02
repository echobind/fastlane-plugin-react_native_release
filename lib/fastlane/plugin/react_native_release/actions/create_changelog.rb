require 'fastlane/action'

module Fastlane
  module Actions
    class CreateChangelogAction < Action
      def self.run(params)
        title = params[:title]
        commit_message = params[:commit_message]
        # Determine our local branch name, set the upstream, and pull.
        # We need to pull since another build may have already finished and created a changelog
        local_branch ||= other_action.git_branch.gsub(/origin/, '')
        sh("git branch --set-upstream-to=origin/#{local_branch} #{local_branch}")
        other_action.git_pull 

        # Get release notes since last version
        # This exports a slack and a regular markdown format
        notes = other_action.conventional_changelog(title: title, format: 'slack')
        notesMD = other_action.conventional_changelog(title: title, format: 'markdown')

        # Prepend new Changelog to existing one
        UI.message("pre-pending to CHANGELOG")
        UI.message(notes)
        new_file = '../CHANGELOG.md.new'
        original_file = '../CHANGELOG.md'

        open(new_file, 'w') do |nf|
          notesMD.split("\n").each { |line| nf.puts line }
          nf.puts "\n"
          
          File.foreach(original_file) do |li|
            nf.puts li
          end
        end

        File.delete original_file
        File.rename new_file, original_file

        # Commit it
        other_action.git_commit(
          path: [File.join(Dir.pwd, original_file)],
          message: commit_message,
          skip_git_hooks: true
        )

        { plain: notes, markdown: notesMD }
      end

      #####################################################
      # @!group documentation
      #####################################################

      def self.description
        "Determines if a release should happen based on conventional commits."
      end

      def self.details
        "If using conventional commits, only continues to release if there are features / fixes."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :title,
                                       env_name: "FL_CREATE_CHANGELOG_TITLE",
                                       description: "What title should we use for the CHANGELOG?",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :commit_message,
                                       env_name: "FL_CREATE_CHANGELOG_COMMIT_MESSAGE",
                                       description: "What should the commit message be?",
                                       type: String,
                                       default_value: "chore(changelog): Update CHANGELOG [skip ci]")
        ]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # "Saves the current vars in android/fastlane/.env and ios/fastlane/.env"
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["cball"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
