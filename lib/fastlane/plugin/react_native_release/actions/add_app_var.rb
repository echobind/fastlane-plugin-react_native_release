require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class AddAppVarAction < Action
      def self.run(params)
        is_ci = ENV['CI'] === 'true'
        namespace = params[:namespace]
        key = params[:key]
        value = params[:value]
        cryptex_app_key = app_key_for(namespace)
        existing_app_vars = {}

        if !is_ci && !UI.confirm("This will add #{key}=#{value} to the #{cryptex_app_key} namespace in the encrypted context repo. Proceed?")
          UI.abort_with_message!("Stepping away...")
        end

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
          hash: existing_app_vars.merge({ key => value })
        )

        UI.success('Encrypted app ENV vars')
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Adds a single ENV var to the encrypted repository"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :namespace,
                                       env_name: "FL_ADD_APP_VAR_NAMESPACE",
                                       description: "What namespace should we use? (alpha, beta, release, ENTER = root)", # a short description of this parameter
                                       type: String,
                                       verify_block: lambda do |value|
                                        unless Helper::ReactNativeReleaseHelper::VALID_NAMESPACES.include?(value)
                                          UI.user_error!("Invalid namespace #{value}. Valid targets are #{Helper::ReactNativeReleaseHelper::VALID_NAMESPACES.join(', ')}") 
                                          next
                                        end
                                      end),
          FastlaneCore::ConfigItem.new(key: :key,
                                       env_name: "FL_ADD_APP_VAR_KEY",
                                       description: "Enter the ENV name",
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :value,
                                       env_name: "FL_ADD_APP_VAR_VALUE",
                                       description: "Enter the ENV value",
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
        ["cball", "isaiahgrey93"]
      end

      def self.is_supported?(platform)
        [:ios, :android].include?(platform)
      end

      # Returns the app key for cryptex. optionally namespaced
      def self.app_key_for(namespace)
        default_app_key = Helper::ReactNativeReleaseHelper::APP_CRYPTEX_KEY 
        return default_app_key if namespace.strip.empty?

        "#{namespace}_#{default_app_key}"
      end
    end
  end
end
