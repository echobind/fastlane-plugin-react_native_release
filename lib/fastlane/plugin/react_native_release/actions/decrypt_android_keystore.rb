require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class DecryptAndroidKeystoreAction < Action
      def self.run(params)
        key = Helper::ReactNativeReleaseHelper::ANDROID_KEYSTORE_CRYPTEX_KEY
        file = Helper::ReactNativeReleaseHelper::ANDROID_KEYSTORE_PATH

        begin
          env_file_exists = File.exists?(file)

          if (env_file_exists && UI.confirm("This will overwrite your existing .env file. Proceed?"))
            self.export_and_decrypt_keystore(file,key)
            
          elsif(env_file_exists)
            UI.abort_with_message!("Stepping away...")
          else
            self.export_and_decrypt_keystore(file,key)
          end
        # If we don't have a keystore, cryptex will throw an exception.
        rescue => ex
          UI.abort_with_message!('Error decrypting keystore. Does it exist in the repo?')
        end

        UI.success("Decrypted #{key} to keystore.")
      end

      def self.export_and_decrypt_keystore(file,key)
        other_action.cryptex(
          type: "export",
          out: file,
          key: key,
          verbose: true
        )
         # There is currently a bug where the keystore needs to be in multiple paths
         # Optimized for the CI process to be running from the lane in android directory
         sh("cp ./app/android.keystore ./")
      end

      # Creates a new android keystore based on the provided params. Wraps Cryptex.
      def self.create_keystore_with_params(params)
        begin
          other_action.cryptex_generate_keystore(
            destination: params[:destination],
            password: params[:password],
            fullname: params[:fullname],
            city: params[:city],
            alias: params[:alias]
          )
        rescue => ex
          UI.abort_with_message!("Could not create keystore. Do you already have one with this alias?")
        end

        params[:destination]
      end

      # Saves a keystore to the repo. Note this will overwrite it!
      def self.encrypt_keystore(keystore_path)
        key = Helper::ReactNativeReleaseHelper::ANDROID_KEYSTORE_CRYPTEX_KEY

        other_action.cryptex(
          type: "import",
          in: keystore_path,
          key: key
        )
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
        [
          FastlaneCore::ConfigItem.new(key: :encrypt_in_repo,
                                       env_name: "FL_GENERATE_ANDROID_KEYSTORE_ENCRYPT_IN_REPO",
                                       description: "If the new keystore should be encrypted and saved",
                                       type: Boolean,
                                       default_value: false),
          FastlaneCore::ConfigItem.new(key: :password,
                                       env_name: "FL_GENERATE_ANDROID_KEYSTORE_PASSWORD",
                                       description: "Password for the Keystore",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :alias,
                                       env_name: "FL_GENERATE_ANDROID_KEYSTORE_ALIAS",
                                       description: "ALIAS for the Keystore",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :destination,
                                       env_name: "FL_GENERATE_ANDROID_KEYSTORE_DESTINATION",
                                       description: "Where to put decrypted keystore",
                                       default_value: "../android/app/android.keystore"),
          FastlaneCore::ConfigItem.new(key: :fullname,
                                       env_name: "FL_GENERATE_ANDROID_KEYSTORE_FULLNAME",
                                       description: "Fullname of keystore owner",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :city,
                                       env_name: "FL_GENERATE_ANDROID_KEYSTORE_CITY",
                                       description: "City of keystore owner",
                                       type: String),
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
        ["cball", "isaiahgrey93", "cmejet"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end
    end
  end
end
