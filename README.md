# React Native Release 

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-react_native_release)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-react_native_release`, add it to your project by running:

```bash
fastlane add_plugin react_native_release
```

### Ensure your project confirms to Semantic Versioning
Projects using React Native Release should use Semantic Versioning. At the very least, you need major, minor, and patch numbers in your version.

**iOS**
Use `agvtool` to get and set a version across your project. From the `ios` directory, do the following:
* `agvtool what-marketing-version` to see your current version
* `agvtool new-marketing-version 0.1.0` to set a new version

**Android**
* Set `versionName` in `app/build.gradle`. (`versionName "0.1.0"`)

:exclamation: If you don't complete these steps, releases will fail. :exclamation:

### Configuring builds to TestFlight and AppStore Connect on CI

To upload builds to TestFlight or AppStore Connect, your CI will need a session cookie that was generated with a 2FA code. React Native Release generates and stores this code securely in Github, when the local release script runs, and CI consumes the cookie during the IOS build upload step for jobs uploading to TestFlight or AppStore Connect.

To enable the fastlane session add an `.env` file at `<root>/fastlane/.env` with the following configuration.

| KEY | TYPE | DESCRIPTION |
|-----|------|-------------|
| FASTLANE_ENV_GIT_URL | String | The repository where the hashed session token will be stored. **Ensure this repository before running the release script!** (Must be a separate repository solely for securely storing the session token). |
| FASTLANE_ENV_USERNAME | String | The Apple Developer Account email to authenticate with 2FA and generate a session token for. |

Note: Apple requires 2FA on all accounts now and the IOS build steps will fail if you attempt to upload to TestFlight or AppStore Connect without a session token.

## About React Native Release

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

Here's what it looks like in action:
![Releasing a beta](https://api.monosnap.com/image/download?id=IEISpG4vgMeGPl31it8GxPbiTror2i)
(this example uses `"release": "bundle exec fastlane run react_native_release"` as a yarn script)

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
