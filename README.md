# React Native Release

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-react_native_release)

Simplify releases for your React Native apps. This plugin contains many actions to help you with your release workflow.

It helps cut a new `beta` or `release` version of your app:

- Authenticates and stores an encrypted App Store Connect session that is later used for TestFlight and App Store operations
- Prompts the user for a `major/minor/patch` version bump
- Bumps the version of the iOS and Android app appropriately
- Creates a tag
- Handles hotfix releases
- Handles merging version bumps and hotfixes back to the appropriate branches

It encrypts, and on CI, decrypts values from a standalone "context" git repository:

- Android keystore file (including helping you generate one)
- Google Play Credentials to upload to the Play Store
- Fastlane config ENV variables
- App ENV variables (API_URL, feature flags, etc)

### Philosophies

**Use Fastlane Match**

Certificates and provisioning profiles should be created and managed by Fastlane Match

**Builds Run on CI**

We support local builds for projects, but they should only be used in emergency situations.

**CI uses a machine user**

This is a best practice.

**ENV vars are managed through React Native Release**

We do this for portability and ease of configuration. Outside of the ENV vars to configure CRYPTEX, you shouldn't have to add ENV vars to CI.

For App ENV vars, we provide some additional functionality via namespaces. Valid namespaces are `alpha`, `beta`, `release`, and empty (root). Root ENV vars are "global". Namespaced variables are merged into the Root ENV vars at build time via the `decrypt_app_vars` action. This allows you to easily overwrite ENV vars for specific types of builds, all without configuring separate targets and schemes in XCode.

The main branch and tagging flow looks like this (note this may be out of date. Revisit after workflow updates):

![Branch / Tag Flow](https://monosnap.com/image/Tn71leeWdCwwjSdwjYKHK4pnyjG1v4.png)

If a hotfix is required the flow looks like this (note this may be out of date. Revisit after workflow updates):

![Hotfix Flow](https://monosnap.com/image/ctwlef0A3TbLbRk1xJrlVroNB8F9ot.png)

Here's what it looks like in action:
![Releasing a beta](https://api.monosnap.com/image/download?id=IEISpG4vgMeGPl31it8GxPbiTror2i)
(this example uses `"release": "bundle exec fastlane run react_native_release"` as a yarn script)e

## Prerequisites

### Ensure your project confirms to Semantic Versioning

Projects using React Native Release should use Semantic Versioning. At the very least, you need major, minor, and patch numbers in your version.

**iOS**
Use `agvtool` to get and set a version across your project. From the `ios` directory, do the following:

- `agvtool what-marketing-version` to see your current version
- `agvtool new-marketing-version 0.1.0` to set a new version

**Android**

- Set `versionName` in `app/build.gradle`. (`versionName "0.1.0"`)

:exclamation: If you don't complete these steps, releases will fail. :exclamation:

## Installation

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. Since React Native projects contain both `iOS` and `Android` apps, we need to install the plugin in multiple places:

1. In the root of your project. This is used to run release commands over the entire project.

```bash
fastlane add_plugin react_native_release
```

2. In `./android/fastlane`

```bash
fastlane add_plugin react_native_release
```

3. In `./ios/fastlane`

```bash
fastlane add_plugin react_native_release
```

### ENV files

We leverage `.env` files in a number of different places.

`<root>/fastlane/.env`:

| KEY               | TYPE    | DESCRIPTION                                                                                                                                                                                   |
| ----------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CRYPTEX_GIT_URL   | String  | The repository where the hashed session token will be stored. **Ensure this repository before running the release script!** (You can leverage the same repository you use for Fastlane Match) |
| CRYPTEX_PASSWORD  | String  | The secret key used to encrypt/decrypt the `FASTLANE_SESSION` value.                                                                                                                          |
| CRYPTEX_SKIP_DOCS | Boolean | Force the underlying encryption plugin to skip README generation.                                                                                                                             |

`<root>/android/fastlane/.env`:

| KEY                  | TYPE    | DESCRIPTION                                                                                                                                                                                   |
| -------------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ANDROID_KEY_PASSWORD | String  | The password generated from `generate_android_keystore` or a manual keystore command.`                                                                                                        |
| ANDROID_KEY_ALIAS    | String  | The alias for the keystore                                                                                                                                                                    |
| CRYPTEX_GIT_URL      | String  | The repository where the hashed session token will be stored. **Ensure this repository before running the release script!** (You can leverage the same repository you use for Fastlane Match) |
| CRYPTEX_PASSWORD     | String  | The secret key used to encrypt/decrypt the `FASTLANE_SESSION` value.                                                                                                                          |
| CRYPTEX_SKIP_DOCS    | Boolean | Force the underlying encryption plugin to skip README generation.                                                                                                                             |

`<root>/ios/fastlane/.env`:

| KEY               | TYPE    | DESCRIPTION                                                                                                                                                                                   |
| ----------------- | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| MATCH_GIT_URL     | String  | The repository used for Fastlane match. Typically the same as CRYPTEX_GIT_URL                                                                                                                 |
| MATCH_PASSWORD    | String  | The password used to encrypt / decrypt Fastlane Match certs and profiles                                                                                                                      |
| GYM_WORKSPACE     | String  | The name of the workspace file (Myproject.xcworkspace)                                                                                                                                        |
| GYM_SCHEME        | String  | The scheme to build within the workspace (Myproject)                                                                                                                                          |
| GYM_OUTPUT_NAME   | String  | The name of the `.ipa` file to output (Myproject)                                                                                                                                             |
| CRYPTEX_GIT_URL   | String  | The repository where the hashed session token will be stored. **Ensure this repository before running the release script!** (You can leverage the same repository you use for Fastlane Match) |
| CRYPTEX_PASSWORD  | String  | The secret key used to encrypt/decrypt the `FASTLANE_SESSION` value.                                                                                                                          |
| CRYPTEX_SKIP_DOCS | Boolean | Force the underlying encryption plugin to skip README generation.                                                                                                                             |

**Note: In followup releases, we will add a `react-native-release init` script to generate these for you.**

### Configuring builds to upload to TestFlight and AppStore Connect on CI

To upload builds to TestFlight or AppStore Connect, CI will need to restore a previously generated session. While possible to use an Application Specific Password to upload builds, it will not have the additional permissions required for other TestFlight / App Store operations. As such, we require generating a session.

## Example

See /example to see how to use the plugin.

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
