require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class DecryptFastlaneVarsAction < Action
      def self.run(params)

        is_ci = ENV['CI'] === 'true'
        write_env = params[:write_env]

        env = other_action.cryptex(
          type: "export_env",
          key: Helper::ReactNativeReleaseHelper::FASTLANE_CRYPTEX_KEY,
          set_env: params[:set_env]
        )

        should_write_env = write_env && !is_ci


        UI.success('Successfully decrypted fastlane vars.')

        # write fastlane env files
        if (should_write_env)

          UI.success('Writing fastlane vars to <root>/fastlane/.env.')
          
          open('./fastlane/.env', 'w') do |f|
            env.each {|key, value| f.puts "#{key}=#{value}" }
          end
 
          UI.success('Writing fastlane vars to <root>/ios/fastlane/.env.')
          
          open('./ios/fastlane/.env', 'w') do |f|
            env.each {|key, value| f.puts "#{key}=#{value}" }
          end
 
          UI.success('Writing fastlane vars to <root>/android/fastlane/.env.')
          
          open('./android/fastlane/.env', 'w') do |f|
            env.each {|key, value| f.puts "#{key}=#{value}" }
          end

          UI.success('Fastlane .env files were successfully written.')
        else
          UI.success('Fastlane .env not generated.')
        end

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
                                       default_value: true),
          FastlaneCore::ConfigItem.new(key: :write_env,
                                       env_name: "FL_DECRYPT_FASTLANE_VARS_WRITE_ENV", # The name of the environment variable
                                       description: "If we should write fastlane .env files", # a short description of this parameter
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
