require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class ReactNativeReleaseHelper
      FASTLANE_CRYPTEX_KEY = 'fastlane_vars'
      APP_CRYPTEX_KEY = 'app_vars'
      APP_ENV_PATH = '.env'
      VALID_NAMESPACES = ['alpha', 'beta', 'release', ''] # empty string denotes root namespace
      ANDROID_KEYSTORE_CRYPTEX_KEY = 'ANDROID_KEYSTORE'
      ANDROID_KEYSTORE_PATH = "android/app/android.keystore"
      GOOGLE_PLAY_CREDENTIALS_CRYPTEX_KEY = 'GOOGLE_PLAY_CREDS'
      FASTLANE_SESSION_CRYPTEX_KEY = 'FASTLANE_SESSION'

      # returns an app key for a specific namespace. Ex: beta_app_vars
      def self.app_key_for(namespace)
        return APP_CRYPTEX_KEY if namespace.strip.empty?

        "#{namespace}_#{APP_CRYPTEX_KEY}"
      end
    end
  end
end
