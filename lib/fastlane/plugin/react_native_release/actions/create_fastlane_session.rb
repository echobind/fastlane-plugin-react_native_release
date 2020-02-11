require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class CreateFastlaneSessionAction < Action
      def self.run(params)
        username = params[:username]
        key = Helper::ReactNativeReleaseHelper::FASTLANE_SESSION_CRYPTEX_KEY
        fastlane_key = Helper::ReactNativeReleaseHelper::FASTLANE_CRYPTEX_KEY
        fastlane_session_cookie_path = "#{File.expand_path('~')}/.fastlane/spaceship/#{username}/cookie"

        UI.message "Generating a new fastlane session."
        UI.message "Please enter the 6 digit 2FA code if one is sent to your device otherwise the script will continue automatically."
        
        sh("fastlane spaceauth -u #{username.shellescape}")

        # store the session
        other_action.cryptex(
          type: "import",
          in: fastlane_session_cookie_path,
          key: key
        )

        # store the username that created the session in fastlane_vars
        existing_fastlane_vars = other_action.cryptex(
          type: 'export_env',
          key: fastlane_key,
        )

        other_action.cryptex(
          type: "import_env",
          key: fastlane_key,
          # PILOT_USERNAME needs to be set to the same username as the session above
          hash: existing_fastlane_vars.merge({ 'PILOT_USERNAME' => username })
        )

        UI.success "Uploaded session for #{username} to #{key}."
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

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :username,
                                       env_name: "FL_CREATE_FASTLANE_SESSION_USERNAME",
                                       description: "Enter the Apple username to generate a App Store Connect session",
                                       type: String)
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
