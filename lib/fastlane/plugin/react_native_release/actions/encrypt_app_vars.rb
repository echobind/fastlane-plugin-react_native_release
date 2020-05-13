require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class EncryptAppVarsAction < Action
      def self.run(params)
        namespace = params[:namespace]
        cryptex_app_key = app_key_for(namespace)
        env_path = params[:env_path] || env_path_for(namespace)

        if !File.exists?(env_path)
          UI.user_error!("#{env_path} not found!")
        end

        if !UI.confirm("This will save values from #{env_path} to the #{cryptex_app_key} namespace in the encrypted context repo. Proceed?")
          UI.abort_with_message!("Stepping away...")
        end

        app_vars = Dotenv.parse(env_path)
        existing_app_vars = {}

        begin
          existing_app_vars = other_action.cryptex(
            type: 'export_env',
            key: cryptex_app_key,
          )
        rescue => ex
          # If key doesn't exist cryptex will error
        end

        other_action.cryptex(
          type: "import_env",
          key: cryptex_app_key,
          hash: existing_app_vars.merge(app_vars)
        )

        UI.success('Encrypted app ENV vars')
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Encrypts app env vars and stores them in the context repo."
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :namespace,
                                       env_name: "FL_ENCRYPT_APP_VARS_NAMESPACE", # The name of the environment variable
                                       description: "What namespace should we use? (alpha, beta, release, ENTER = root)", # a short description of this parameter
                                       type: String,
                                       short_option: "-n",
                                       verify_block: lambda do |value|
                                        unless Helper::ReactNativeReleaseHelper::VALID_NAMESPACES.include?(value)
                                          UI.user_error!("Invalid namespace #{value}. Valid targets are #{Helper::ReactNativeReleaseHelper::VALID_NAMESPACES.join(', ')}") 
                                          next
                                        end
                                      end),
          FastlaneCore::ConfigItem.new(key: :env_path,
                                       env_name: "FL_ENCRYPT_APP_VARS_ENV_PATH", # The name of the environment variable
                                       description: "A path to an ENV file that contains app related ENV vars", # a short description of this parameter
                                       type: String,
                                       short_option: "-p",
                                       optional: true)
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

      # Returns a path for an env var. optionally namespaced
      def self.env_path_for(namespace)
        return default_env_path if namespace.strip.empty?
        "#{default_env_path}.#{namespace}"
      end

      # Returns the app key for cryptex. optionally namespaced
      def self.app_key_for(namespace)
        default_app_key = Helper::ReactNativeReleaseHelper::APP_CRYPTEX_KEY 
        return default_app_key if namespace.strip.empty?

        "#{namespace}_#{default_app_key}"
      end

      def self.default_env_path
        Helper::ReactNativeReleaseHelper::APP_ENV_PATH
      end
    end
  end
end
