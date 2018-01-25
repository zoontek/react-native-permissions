# ☝🏼 React Native Permissions

[![npm version](https://badge.fury.io/js/react-native-permissions.svg)](https://badge.fury.io/js/react-native-permissions)
[![npm](https://img.shields.io/npm/dt/react-native-permissions.svg)](https://www.npmjs.org/package/react-native-permissions)
![Platform - Android and iOS](https://img.shields.io/badge/platform-Android%20%7C%20iOS-yellow.svg)
![MIT](https://img.shields.io/dub/l/vibe-d.svg)
[![styled with prettier](https://img.shields.io/badge/styled_with-prettier-ff69b4.svg)](https://github.com/prettier/prettier)

Request user permissions from React Native, iOS + Android

| Version | React Native Support |
| ------- | -------------------- |
| 1.0.6   | 0.40 - 0.51          |
| 0.2.5   | 0.33 - 0.39          |

_Complies with
[react-native-version-support-table](https://github.com/dangnelson/react-native-version-support-table)_

## ⚠️ Breaking changes in version 1.0.0

* Now using React Native's own JS `PermissionsAndroid` module on Android, which
  is great because we no longer have to do any additional linking on Android
* Updated API to be closer to React Native's `PermissionsAndroid`
* Removed `openSettings()` support on Android (to stay linking-free). There are
  several NPM modules available for this
* `restricted` status now supported on Android, although it means something
  different than iOS

## Setup

```sh
npm install --save react-native-permissions
# --- or ---
yarn add react-native-permissions
```

_📌 Don't forget to add permissions to `AndroidManifest.xml` for android and
`Info.plist` for iOS (Xcode >= 8). See [iOS Notes](#ios-notes) or [Android Notes](#android-notes) for more details._

### Additional iOS setup

#### Using cocoaPods

Update the following line with your path to `node_modules/` and add it to your
podfile:

```ruby
pod 'ReactNativePermissions', :path => '../node_modules/react-native-permissions'
```

#### Using react-native link

```sh
react-native link react-native-permissions
```

#### Using manual linking

1. In the XCode's "Project navigator", right click on your project's Libraries
   folder ➜ `Add Files to <...>`
2. Go to `node_modules` ➜ `react-native-permissions` ➜ select
   `ReactNativePermissions.xcodeproj`
3. Add `libReactNativePermissions.a` to `Build Phases` -> `Link Binary With
   Libraries`

## Using

```js
import Permissions from 'react-native-permissions'
// OR const Permissions = require('react-native-permissions').default
// if you use CommonJS module system

//...

export default class extends React.Component {
  //...

  // Check the status of a single permission
  componentDidMount() {
    Permissions.check('photo').then(response => {
      // Response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
      this.setState({ photoPermission: response })
    })
  }

  // Request permission to access photos
  _requestPermission = () => {
    Permissions.request('photo').then(response => {
      // Returns once the user has chosen to 'allow' or to 'not allow' access
      // Response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
      this.setState({ photoPermission: response })
    })
  }

  // Check the status of multiple permissions
  _checkCameraAndPhotos = () => {
    Permissions.checkMultiple(['camera', 'photo']).then(response => {
      //response is an object mapping type to permission
      this.setState({
        cameraPermission: response.camera,
        photoPermission: response.photo,
      })
    })
  }

  // This is a common pattern when asking for permissions.
  // iOS only gives you once chance to show the permission dialog,
  // after which the user needs to manually enable them from settings.
  // The idea here is to explain why we need access and determine if
  // the user will say no, so that we don't blow our one chance.
  // If the user already denied access, we can ask them to enable it from settings.
  _alertForPhotosPermission() {
    Alert.alert(
      'Can we access your photos?',
      'We need access so you can set your profile pic',
      [
        {
          text: 'No way',
          onPress: () => console.log('Permission denied'),
          style: 'cancel',
        },
        this.state.photoPermission == 'undetermined'
          ? { text: 'OK', onPress: this._requestPermission }
          : { text: 'Open Settings', onPress: Permissions.openSettings },
      ],
    )
  }

  //...
}
```

## API

### Permissions statuses

Promises resolve into one of these statuses:

| Return value   | Notes                                                                                                                                                                                                                                                                  |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `authorized`   | User has authorized this permission                                                                                                                                                                                                                                    |
| `denied`       | User has denied this permission at least once. On iOS this means that the user will not be prompted again. Android users can be prompted multiple times until they select 'Never ask me again'                                                                          |
| `restricted`   | **iOS** - this means user is not able to grant this permission, either because it's not supported by the device or because it has been blocked by parental controls. **Android** - this means that the user has selected 'Never ask me again' while denying permission |
| `undetermined` | User has not yet been prompted with a permission dialog                                                                                                                                                                                                                |

### Supported permissions types

The current supported permissions are:

|                    | Type                | iOS | Android |
| ------------------ | ------------------- | --- | ------- |
| Location           | `location`          | ✔️  | ✔       |
| Camera             | `camera`            | ✔️  | ✔       |
| Microphone         | `microphone`        | ✔️  | ✔       |
| Photos             | `photo`             | ✔️  | ✔       |
| Contacts           | `contacts`          | ✔️  | ✔       |
| Events             | `event`             | ✔️  | ✔       |
| Bluetooth          | `bluetooth`         | ✔️  | ❌      |
| Reminders          | `reminder`          | ✔️  | ❌      |
| Push Notifications | `notification`      | ✔️  | ❌      |
| Background Refresh | `backgroundRefresh` | ✔️  | ❌      |
| Speech Recognition | `speechRecognition` | ✔️  | ❌      |
| mediaLibrary       | `mediaLibrary`      | ✔️  | ❌      |
| Motion Activity    | `motion`            | ✔️  | ❌      |
| Storage            | `storage`           | ❌️ | ✔       |
| Phone Call         | `callPhone`         | ❌️ | ✔       |
| Read SMS           | `readSms`           | ❌️ | ✔       |
| Receive SMS        | `receiveSms`        | ❌️ | ✔       |

### Methods

| Method Name         | Arguments | Notes                                                                                                                                                                                                                                                                            |
| ------------------- | --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `check()`           | `type`    | - Returns a promise with the permission status. See iOS Notes for special cases                                                                                                                                                                                                  |
| `request()`         | `type`    | - Accepts any permission type except `backgroundRefresh`. If the current status is `undetermined`, shows the permission dialog and returns a promise with the resulting status. Otherwise, immediately return a promise with the current status. See iOS Notes for special cases |
| `checkMultiple()`   | `[types]` | - Accepts an array of permission types and returns a promise with an object mapping permission types to statuses                                                                                                                                                                 |
| `getTypes()`        | _none_    | - Returns an array of valid permission types                                                                                                                                                                                                                                     |
| `openSettings()`    | _none_    | - _(iOS only - 8.0 and later)_ Switches the user to the settings page of your app                                                                                                                                                                                                |
| `canOpenSettings()` | _none_    | - _(iOS only)_ Returns a boolean indicating if the device supports switching to the settings page                                                                                                                                                                                |

### iOS Notes

* Permission type `bluetooth` represents the status of the
  `CBPeripheralManager`. Don't use this if only need `CBCentralManager`
* Permission type `location` accepts a second parameter for `request()` and
  `check()`; the second parameter is a string, either `always` or `whenInUse`
  (default).
* Permission type `notification` accepts a second parameter for `request()`. The
  second parameter is an array with the desired alert types. Any combination of
  `alert`, `badge` and `sound` (default requests all three).
* If you are not requesting mediaLibrary then you can remove MediaPlayer.framework from the xcode project

```js
// example
Permissions.check('location', { type: 'always' }).then(response => {
  this.setState({ locationPermission: response })
})

Permissions.request('location', { type: 'always' }).then(response => {
  this.setState({ locationPermission: response })
})

Permissions.request('notification', { type: ['alert', 'badge'] }).then(
  response => {
    this.setState({ notificationPermission: response })
  },
)
```

* You cannot request microphone permissions on the simulator.
* With Xcode 8, you now need to add usage descriptions for each permission you
  will request. Open Xcode ➜ `Info.plist` ➜ Add a key (starting with "Privacy -
  ...") with your kit specific permission.

Example: If you need Contacts permission you have to add the key `Privacy -
Contacts Usage Description`.

<img width="338" alt="3cde3b44-7ffd-11e6-918b-63888e33f983" src="https://cloud.githubusercontent.com/assets/1440796/18713019/271be540-8011-11e6-87fb-c3828c172dfc.png">

#### App Store submission disclaimer

If you need to submit you application to the AppStore, you need to add to your
`Info.plist` all `*UsageDescription` keys with a string value explaining to the
user how the app uses this data. **Even if you don't use them**.

So before submitting your app to the App Store, make sure that in your
`Info.plist` you have the following keys:

```xml
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Some description</string>
<key>NSCalendarsUsageDescription</key>
<string>Some description</string>
<key>NSCameraUsageDescription</key>
<string>Some description</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Some description</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Some description</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Some description</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Some description</string>
<key>NSAppleMusicUsageDescription</key>
<string>Some description</string>
<key>NSMotionUsageDescription</key>
<string>Some description</string>

This is required because during the phase of processing in the App Store
submission, the system detects that you app contains code to request the
permission `X` but don't have the `UsageDescription` key and then it rejects the
build.

> Please note that it will only be shown to the users the usage descriptions of
> the permissions you really require in your app.

You can find more information about this issue in #46.

### Android Notes

* Uses React Native's own
  [`PermissionsAndroid` JS API](http://facebook.github.io/react-native/docs/permissionsandroid.html).
* All required permissions also need to be included in the `AndroidManifest.xml`
  file before they can be requested. Otherwise `request()` will immediately
  return `denied`.
* You can request write access to any of these types by also including the
  appropriate write permission in the `AndroidManifest.xml` file. Read more
  [here](https://developer.android.com/guide/topics/security/permissions.html#normal-dangerous).

* The optional rationale argument will show a dialog prompt.

```js
// example
Permissions.request('camera', {
  rationale: {
    title: 'Cool Photo App Camera Permission',
    message:
      'Cool Photo App needs access to your camera ' +
      'so you can take awesome pictures.',
  },
}).then(response => {
  this.setState({ cameraPermission: response })
})
```

* Permissions are automatically accepted for **targetSdkVersion < 23** but you
  can still use `check()` to check if the user has disabled them from Settings.

You might need to elevate the **targetSdkVersion** version in your
`build.gradle`:

```groovy
android {
  compileSdkVersion 23 // ← set at least 23
  buildToolsVersion "23.0.1"  // ← set at least 23.0.0

  defaultConfig {
    minSdkVersion 16
    targetSdkVersion 23 // ← set at least 23
    // ...
```

## Troubleshooting

#### Q: iOS - App crashes as soon as I request permission

> A: Starting with Xcode 8, you need to add permission descriptions. See iOS
> notes for more details. Thanks to [@jesperlndk](https://github.com/jesperlndk)
> for discovering this.

#### Q: iOS - App crashes when I change permission from settings

> A: This is normal. iOS restarts your app when your privacy settings change.
> Just google "iOS crash permission change"
