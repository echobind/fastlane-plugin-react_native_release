require 'fastlane/plugin/react_native_release/version'

module Fastlane
  module ReactNativeRelease
    # Return all .rb files inside the "actions" and "helper" directory
    def self.all_classes
      Dir[File.expand_path('**/{actions,helper}/*.rb', File.dirname(__FILE__))]
    end
  end
end

# By default we want to import all available actions and helpers
# A plugin can contain any number of actions and plugins
Fastlane::ReactNativeRelease.all_classes.each do |current|
  require current
end
