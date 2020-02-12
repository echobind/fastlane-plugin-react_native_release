require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class DecryptFastlaneVarsAction < Action
      def self.run(params)

        env = other_action.cryptex(
          type: "export_env",
          key: Helper::ReactNativeReleaseHelper::FASTLANE_CRYPTEX_KEY,
          set_env: params[:set_env]
        )

        UI.success('Decrypted fastlane vars')
        
        env
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Decrypts fastlane ENV vars from the encrypted repo. Optionally sets them in ENV."
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
      end

      def self.available_options
        # Define all options your action supports. 
        
        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :set_env,
                                       env_name: "FL_DECRYPT_FASTLANE_VARS_SET_ENV", # The name of the environment variable
                                       description: "Sets the decrypted values in env", # a short description of this parameter
                                       type: Boolean,
                                       default_value: true)
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
        ["cball", "isaiahgrey93"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
