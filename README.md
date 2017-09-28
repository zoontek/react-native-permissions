# React Native Permissions
Request user permissions from React Native, iOS + Android

The current supported permissions are:
- Location
- Camera
- Microphone
- Photos
- Contacts
- Events
- Reminders *(iOS only)*
- Bluetooth *(iOS only)*
- Push Notifications *(iOS only)*
- Background Refresh *(iOS only)*
- Speech Recognition *(iOS only)*
- Call Phone *(Android Only)*
- Read/Receive SMS *(Android only)*


| Version | React Native Support |
|---|---|
| 1.0.1 | 0.40.0 - 0.48.4 |
| 0.2.7 | 0.40.0 - 0.41.0 |
| 0.2.5 | 0.33.0 - 0.39.0 |
*Complies with [react-native-version-support-table](https://github.com/dangnelson/react-native-version-support-table)*

### Breaking changes in version 1.0.0
  - Now using React Native's own JS PermissionsAndroid library on Android, which is great because now we no longer have to do any additional linking (on Android)
  - Updated API to be closer to RN's PermissionsAndroid
  - Removed `openSettings()` support on Android (to stay linking-free). There are several NPM modules available for this
  - `restricted` status now supported on Android, although it means something different than iOS

## General Usage
```
npm install --save react-native-permissions
react-native link
```

Add permissions to manifest for android and info.plist for ios (xcode >=8). See notes below for more details.

```js
const Permissions = require('react-native-permissions');

//...
  //check the status of a single permission
  componentDidMount() {
    Permissions.check('photo')
      .then(response => {
        //response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
        this.setState({ photoPermission: response })
      });
  }

  //request permission to access photos
  _requestPermission() {
    Permissions.request('photo')
      .then(response => {
        //returns once the user has chosen to 'allow' or to 'not allow' access
        //response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
        this.setState({ photoPermission: response })
      });
  }

  //check the status of multiple permissions
  _checkCameraAndPhotos() {
    Permissions.checkMultiple(['camera', 'photo'])
      .then(response => {
        //response is an object mapping type to permission
        this.setState({
          cameraPermission: response.camera,
          photoPermission: response.photo,
        })
      });
  }

  // this is a common pattern when asking for permissions.
  // iOS only gives you once chance to show the permission dialog,
  // after which the user needs to manually enable them from settings.
  // the idea here is to explain why we need access and determine if
  // the user will say no, so that we don't blow our one chance.
  // if the user already denied access, we can ask them to enable it from settings.
  _alertForPhotosPermission() {
    Alert.alert(
      'Can we access your photos?',
      'We need access so you can set your profile pic',
      [
        {text: 'No way', onPress: () => console.log('permission denied'), style: 'cancel'},
        this.state.photoPermission == 'undetermined'?
          {text: 'OK', onPress: this._requestPermission.bind(this)}
          : {text: 'Open Settings', onPress: Permissions.openSettings}
      ]
    )
  }
//...
```

## API

### Permission statuses
Promises resolve into one of these statuses

| Return value | Notes|
|---|---|
|`authorized`| user has authorized this permission |
|`denied`| user has denied this permission at least once. On iOS this means that the user will not be prompted again. Android users can be promted multiple times until they select 'Never ask me again'|
|`restricted`| **iOS** - this means user is not able to grant this permission, either because it's not supported by the device or because it has been blocked by parental controls. **Android** - this means that the user has selected 'Never ask me again' while denying permission |
|`undetermined`| user has not yet been prompted with a permission dialog |

### Supported permission types

| Name | iOS | Android |
|---|---|---|
|`location`| ✔️ | ✔ |
|`camera`| ✔️ | ✔ |
|`microphone`| ✔️ | ✔ |
|`photo`| ✔️ | ✔ |
|`contacts`| ✔️ | ✔ |
|`event`| ✔️ | ✔ |
|`bluetooth`| ✔️ | ❌ |
|`reminder`| ✔️ | ❌ |
|`notification`| ✔️ | ❌ |
|`backgroundRefresh`| ✔️ | ❌ |
|`speechRecognition`| ✔️ | ❌ |
|`storage`| ❌️ | ✔ |
|`callPhone`| ❌️ | ✔ |
|`readSms`| ❌️ | ✔ |
|`receiveSms`| ❌️ | ✔ |

### Methods
| Method Name | Arguments | Notes
|---|---|---|
| `check()` | `type` | - Returns a promise with the permission status. See iOS Notes for special cases |
| `request()` | `type` | - Accepts any permission type except `backgroundRefresh`. If the current status is `undetermined`, shows the permission dialog and returns a promise with the resulting status. Otherwise, immediately return a promise with the current status. See iOS Notes for special cases|
| `checkMultiple()` | `[types]` | - Accepts an array of permission types and returns a promise with an object mapping permission types to statuses |
| `getTypes()` | *none* | - Returns an array of valid permission types  |
| `openSettings()` | *none* | - *(iOS only - 8.0 and later)* Switches the user to the settings page of your app |
| `canOpenSettings()` | *none* | - *(iOS only)* Returns a boolean indicating if the device supports switching to the settings page |

### iOS Notes
- Permission type `bluetooth` represents the status of the `CBPeripheralManager`. Don't use this if only need `CBCentralManager`
- Permission type `location` accepts a second parameter for `request()` and `check()`;  the second parameter is a string, either `always` or `whenInUse`(default).

- Permission type `notification` accepts a second parameter for `request()`. The second parameter is an array with the desired alert types. Any combination of `alert`, `badge` and `sound` (default requests all three)

```js
///example
    Permissions.check('location', 'always')
      .then(response => {
        this.setState({ locationPermission: response })
      })

    Permissions.request('location', 'always')
      .then(response => {
        this.setState({ locationPermission: response })
      })

    Permissions.request('notification', ['alert', 'badge'])
      .then(response => {
        this.setState({ notificationPermission: response })
      })
```

You cannot request microphone permissions on the simulator.

With Xcode 8, you now need to add usage descriptions for each permission you will request. Open Xcode > Info.plist > Add a key (starting with "Privacy - ...") with your kit specific permission.

Example:
If you need Contacts permission you have to add the key "Privacy - Contacts Usage Description".
<img width="338" alt="3cde3b44-7ffd-11e6-918b-63888e33f983" src="https://cloud.githubusercontent.com/assets/1440796/18713019/271be540-8011-11e6-87fb-c3828c172dfc.png">

### Android Notes

Requires RN >= 0.29.0

Uses RN's own `PermissionsAndroid` JS api (http://facebook.github.io/react-native/releases/0.45/docs/permissionsandroid.html)

All required permissions also need to be included in the Manifest before they can be requested. Otherwise `request()` will immediately return `denied`.

Permissions are automatically accepted for targetSdkVersion < 23 but you can still use `check()` to check if the user has disabled them from Settings.

You can request write access to any of these types by also including the appropriate write permission in the Manifest. Read more here: https://developer.android.com/guide/topics/security/permissions.html#normal-dangerous

## Setup

````
npm install --save react-native-permissions
react-native link
````

### Or manually linking

#### iOS
* Run open node_modules/react-native-permissions
* Drag ReactNativePermissions.xcodeproj into the Libraries group of your app's Xcode project
* Add libReactNativePermissions.a to `Build Phases -> Link Binary With Libraries.

#### Android
  No additional linking required

## AppStore submission disclaimer

If you need to submit you application to the AppStore, you need to add to your `Info.plist` all `*UsageDescription` keys with a string value explaining to the user how the app uses this data. **Even if you don't use them**.

So before submitting your app to the `AppStore`, make sure that in your `Info.plist` you have the following keys:

```

<key>NSBluetoothPeripheralUsageDescription</key>
<string>Some description</string>
<key>NSCalendarsUsageDescription</key>
<string>Some description</string>
<key>NSCameraUsageDescription</key>
<string>Some description</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Some description</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Some description</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Some description</string>

```

This is required because during the phase of `processing` in the `AppStore` submission, the system detects that you app contains code to request the permission `X` but don't have the `UsageDescription` key and rejects the build.

> Please note that it will only be shown to the users the usage descriptions of the permissions you really require in your app.

You can find more informations about this issue in #46.

## Troubleshooting

#### Q: iOS - app crashes as soon as I request permission
A: starting with xcode 8, you need to add permission descriptions. see iOS notes for more details. Thanks to @jesperlndk for discovering this.

#### Q: iOS - app crashes when I change permissions from settings
A: This is normal. iOS restarts your app when your privacy settings change. Just google "ios crash permission change"
