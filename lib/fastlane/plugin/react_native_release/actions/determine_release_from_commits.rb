require 'fastlane/action'

module Fastlane
  module Actions
    class DetermineReleaseFromCommitsAction < Action
      VALID_PLATFORMS = %w{ios android}

      def self.run(params)
        ignore_scopes = params[:commit_ignore_scopes]
        tag_prefix = params[:tag_prefix]
        is_releaseable = analyze_commits(match: "#{tag_prefix}*", ignore_scopes: ignore_scopes)
        next_version = lane_context[SharedValues::RELEASE_NEXT_VERSION]
        next unless is_releaseable

        next_version
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Determines if a release should happen based on conventional commits."
      end

      def self.details
        "If using conventional commits, only continues to release if there are features / fixes."
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :commit_ignore_scopes,
                                       env_name: "FL_DETERMINE_RELEASE_FROM_COMMITS_COMMIT_IGNORE_SCOPES",
                                       description: "What scopes from commits should be ignored?",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :tag_prefix,
                                       env_name: "FL_DETERMINE_RELEASE_FROM_COMMITS_TAG_PREFIX",
                                       description: "The tag prefix to use  (ex. ios/beta)",
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
