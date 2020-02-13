require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class ReadFastlaneSessionAction < Action
      def self.run(params)
        key = Helper::ReactNativeReleaseHelper::FASTLANE_SESSION_CRYPTEX_KEY
        fastlane_session_git_url =  ENV["CRYPTEX_GIT_URL"]
        fastlane_session_password = ENV["CRYPTEX_PASSWORD"]
        fastlane_session_cookie_path = Tempfile.new('')

        UI.message "Reading fastlane session.."

        other_action.cryptex(
          type: "export",
          out: fastlane_session_cookie_path.path,
          key: key,
        )

        fastlane_session = (open fastlane_session_cookie_path.path).read

        UI.message fastlane_session_cookie_path.path
        UI.message fastlane_session

        ENV["FASTLANE_SESSION"] = fastlane_session

        UI.success "Read FASTLANE_SESSION from remote repository."
      end

      def self.description
        "Simplify 2FA authentication for App Store Connect"
      end

      def self.authors
        ["cball", "isaiahgrey93"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "Fetches an encrypted cookie for authenticating with App Store connecting. Handles fetching and decrypting the cookie before setting to the local env."
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
