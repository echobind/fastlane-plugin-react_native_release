# react_native_release plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-react_native_release)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-react_native_release`, add it to your project by running:

```bash
fastlane add_plugin react_native_release
```

## About react_native_release

Simplify releases for React Native apps.

This plugin:

- cuts a new `beta` or `production` release
- prompts the user for a `major/minor/patch` version bump
- bumps the version of the iOS and Android app appropriately
- tags a release based on the iOS and Android version
- handles hotfix releases
- handles merging version bumps and hotfixes back to the appropriate branches

The main branch and tagging flow looks like this:
![Branch / Tag Flow](https://monosnap.com/image/Tn71leeWdCwwjSdwjYKHK4pnyjG1v4.png)

If a hotfix is required the flow looks like this:
![Hotfix Flow](https://monosnap.com/image/ctwlef0A3TbLbRk1xJrlVroNB8F9ot.png)

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin. Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test`.

**Note to author:** Please set up a sample project to make it easy for users to explore what your plugin does. Provide everything that is necessary to try out the plugin in this project (including a sample Xcode/Android project if necessary)

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use

```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
