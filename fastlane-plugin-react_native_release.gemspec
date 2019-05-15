# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/react_native_release/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-react_native_release'
  spec.version       = Fastlane::ReactNativeRelease::VERSION
  spec.author        = 'Chris Ball'
  spec.email         = 'chris@echobind.com'

  spec.summary       = 'Simplify releases for React Native apps.'
  spec.homepage      = "https://github.com/echobind/fastlane-plugin-react_native_release"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  # Don't add a dependency to fastlane or fastlane_re
  # since this would cause a circular dependency

  spec.add_dependency 'fastlane-plugin-android_versioning', '~> 0.5.0'
  spec.add_dependency 'fastlane-plugin-cryptex', '~> 0.1.4'

  spec.add_development_dependency('pry')
  spec.add_development_dependency('bundler')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rubocop', '0.49.1')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
  spec.add_development_dependency('fastlane', '>= 2.112.0')
end
