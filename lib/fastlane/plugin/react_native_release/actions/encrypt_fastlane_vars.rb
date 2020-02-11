require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class EncryptFastlaneVarsAction < Action
      ANDROID_ENV_PATH = "./android/fastlane/.env"
      IOS_ENV_PATH = './ios/fastlane/.env'
      FASTLANE_CRYPTEX_KEY = 'fastlane_vars'

      def self.run(params)
        if !File.exists?(IOS_ENV_PATH)
          UI.user_error!("No .env found in ios directory!")
        end

        if !File.exists?(ANDROID_ENV_PATH)
          UI.user_error!("No .env found in Android directory")
        end

        if !UI.confirm("This will save values from your #{IOS_ENV_PATH} and #{ANDROID_ENV_PATH} to the encrypted context repo. Proceed?")
          UI.abort_with_message!("Stepping away...")
        end

        android_env_vars = Dotenv.parse(ANDROID_ENV_PATH)
        ios_env_vars = Dotenv.parse(IOS_ENV_PATH)
        vars = android_env_vars.merge(ios_env_vars)
    
        other_action.cryptex(
          type: "import_env",
          key: FASTLANE_CRYPTEX_KEY,
          hash: vars,
        )

        UI.success "ENV vars set in context repo."
      end

      def self.description
        "Encrypt fastlane vars for CI"
      end

      def self.authors
        ["cball", "isaiahgrey93"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "Saves the current vars in android/fastlane/.env and ios/fastlane/.env"
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
