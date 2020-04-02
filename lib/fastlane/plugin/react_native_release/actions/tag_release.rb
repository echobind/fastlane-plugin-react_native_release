require 'fastlane/action'

module Fastlane
  module Actions
    class TagReleaseAction < Action
      def self.run(params)
        tag_prefix = params[:tag_prefix]
        next_version = params[:next_version]
        build_number = params[:build_number]

        # Create tag to represent the new version
        # TODO handle the case of not having proper git permissions
        other_action.add_git_tag(tag: "#{tag_prefix}/#{next_version}/#{build_number}")
        other_action.push_git_tags
        other_action.push_to_git_remote
      end

      #####################################################
      # @!group documentation
      #####################################################

      def self.description
        "Tags a release based on a prefix, version, and build numbers"
      end

      def self.details
        # TODO
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :tag_prefix,
                                       env_name: "FL_TAG_RELEASE_TAG_PREFIX"
                                       description: "The prefix for tags (ex. ios/beta, android/beta)",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :next_version,
                                       env_name: "FL_TAG_RELEASE_NEXT_VERSION",
                                       description: "The next version to release",
                                       type: String)
          FastlaneCore::ConfigItem.new(key: :build_number,
                                       env_name: "FL_TAG_RELEASE_BUILD_NUMBER",
                                       description: "The current build number from CI",
                                       type: String)
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
