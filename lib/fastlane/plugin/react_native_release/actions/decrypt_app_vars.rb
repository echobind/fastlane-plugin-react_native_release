require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class DecryptAppVarsAction < Action
      def self.run(params)
        is_ci = ENV['CI'] === 'true'
        namespace = params[:namespace]
        write_env = params[:write_env]
        default_cryptex_app_key = Helper::ReactNativeReleaseHelper::APP_CRYPTEX_KEY
        cryptex_app_key = Helper::ReactNativeReleaseHelper.app_key_for(namespace)
        is_same_key = default_cryptex_app_key == cryptex_app_key
        message = ''

        if is_same_key
          message = "This will decrypt values from #{cryptex_app_key}. Proceed?"
        else
          message = "This will decrypt and merge values from #{cryptex_app_key} into #{default_cryptex_app_key}. Proceed?"
        end

        if !is_ci && !UI.confirm(message)
          UI.abort_with_message!("Stepping away...")
        end

        app_vars = other_action.cryptex(
          type: "export_env",
          key: default_cryptex_app_key
        )

        namespaced_vars = other_action.cryptex(
          type: "export_env",
          key: cryptex_app_key
        )

        merged_vars = app_vars.merge(namespaced_vars)
        has_env_file = File.exists?(Helper::ReactNativeReleaseHelper::APP_ENV_PATH)
        should_write_env = write_env && !is_ci && (!has_env_file || UI.confirm("It looks like you already have an .env file. Overwrite it?"))

        # write an env file with the merged values
        if (should_write_env)
          open('.env', 'w') do |f|
            merged_vars.each {|key, value| f.puts "#{key}=#{value}" }
          end

          UI.success('.env written')
        else
          UI.success('not writing .env')
        end

        merged_vars
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
          FastlaneCore::ConfigItem.new(key: :namespace,
                                       env_name: "FL_DECRYPT_APP_VARS_NAMESPACE", # The name of the environment variable
                                       description: "What namespace should we use? (alpha, beta, release, ENTER = root)", # a short description of this parameter
                                       type: String,
                                       verify_block: lambda do |value|
                                        unless Helper::ReactNativeReleaseHelper::VALID_NAMESPACES.include?(value)
                                          UI.user_error!("Invalid namespace #{value}. Valid targets are #{Helper::ReactNativeReleaseHelper::VALID_NAMESPACES.join(', ')}") 
                                          next
                                        end
                                      end),
          FastlaneCore::ConfigItem.new(key: :write_env,
                                       env_name: "FL_DECRYPT_APP_VARS_WRITE_ENV", # The name of the environment variable
                                       description: "If we should write an .env file", # a short description of this parameter
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
