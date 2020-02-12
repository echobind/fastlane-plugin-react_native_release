require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class DecryptGooglePlayCredentialsAction < Action
      def self.run(params)
        key = Helper::ReactNativeReleaseHelper::GOOGLE_PLAY_CREDENTIALS_CRYPTEX_KEY
        file = Tempfile.new('')

        begin
          other_action.cryptex(
            type: "export",
            key: key,
            out: file.path
          )
        rescue => ex
          UI.abort_with_message!('Error decrypting Google Play Credentials. Did you add them to the repo?')
        end

        google_creds = (open file.path).read
        UI.success("Decrypted #{key}")

        google_creds
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Decrypts app env vars and sets the values in the root .env file"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
      end

      def self.available_options
        []
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
