require 'fastlane/action'
require 'fastlane/plugin/cryptex'

module Fastlane
  module Actions
    class AcceptAndroidSdkLicensesAction < Action
      def self.run(params)
        sh("yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses || if [ $? -ne '141' ]; then exit $?; fi;")
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Accepts Android sdk licenses"
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
