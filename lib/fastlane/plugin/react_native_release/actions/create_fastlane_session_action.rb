require 'fastlane/action'
require_relative '../helper/react_native_release_helper'

module Fastlane
  module Actions
    class CreateFastlaneSessionAction < Action
      def self.run(params)
        require 'fastlane/plugin/cryptex'

        fastlane_session_git_url =  ENV["FASTLANE_ENV_GIT_URL"]
        fastlane_session_username = ENV["FASTLANE_ENV_USERNAME"]
        fastlane_session_password = ENV["CRYPTEX_PASSWORD"]
        fastlane_session_cookie_path = "#{File.expand_path('~')}/.fastlane/spaceship/#{fastlane_session_username}/cookie"

        if !fastlane_session_username
          UI.user_error!("No FASTLANE_ENV_USERNAME var at <root>/fastlane/.env\nFASTLANE_ENV_USERNAME is used to authenticate with the App Store for iOS releases.")
        elsif !fastlane_session_git_url
          UI.user_error!("No FASTLANE_ENV_GIT_URL var at <root>/fastlane/.env\nFASTLANE_ENV_GIT_URL is used to store the App Store Connect session to upload releases on CI.")
        elsif !fastlane_session_password
          UI.user_error!("No CRYPTEX_PASSWORD var at <root>/fastlane/.env\nCRYPTEX_PASSWORD is used to encrypt/decrypt the App Store Connect session.")
        else
          UI.message "Generating a new fastlane session."

          UI.message "Please enter the 6 digit 2FA code if one is sent to your device otherwise the script will continue automatically."
          
          `fastlane spaceauth -u #{fastlane_session_username.shellescape}`

          other_action.cryptex(
            type: "import",
            in: fastlane_session_cookie_path,
            key: "FASTLANE_SESSION",
            git_url: fastlane_session_git_url
          )

          UI.message "Uploaded FASTLANE_SESSION variable securely to git repository."
        end
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
        "Creates a cookie for authenticating with App Store connecting. Handles generating, encrypting, and storing the cookie."
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
