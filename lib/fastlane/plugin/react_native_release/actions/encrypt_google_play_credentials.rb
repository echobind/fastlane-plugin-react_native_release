require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class EncryptGooglePlayCredentialsAction < Action
      def self.run(params)
        key = Helper::ReactNativeReleaseHelper::GOOGLE_PLAY_CREDENTIALS_CRYPTEX_KEY
        json_path = params[:json_path]

        begin
          other_action.cryptex(
            type: "import",
            key: key,
            in: json_path
          )
        rescue => ex
          UI.abort_with_message!('Error encrypting Google Play Credentials.')
        end

        UI.success("Encrypted #{json_path} as #{key}")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Encrypts credentials from Google Play and stores in the context repo."
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :json_path,
                                       env_name: "FL_ENCRYPT_GOOGLE_PLAY_CREDENTIALS_JSON_PATH",
                                       description: "Enter path to the json you downloaded from Google, or drop the file here",
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
        ["cball", "isaiahgrey93"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
