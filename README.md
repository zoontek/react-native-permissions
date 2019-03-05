# ☝🏼 React Native Permissions

[![npm version](https://badge.fury.io/js/react-native-permissions.svg)](https://badge.fury.io/js/react-native-permissions)
[![npm](https://img.shields.io/npm/dt/react-native-permissions.svg)](https://www.npmjs.org/package/react-native-permissions)
![Platform - Android and iOS](https://img.shields.io/badge/platform-Android%20%7C%20iOS-yellow.svg)
![MIT](https://img.shields.io/dub/l/vibe-d.svg)
[![styled with prettier](https://img.shields.io/badge/styled_with-prettier-ff69b4.svg)](https://github.com/prettier/prettier)

Request user permissions on iOS and Android.

### ⚠️  Branch WIP 2.0.0 : Go to [pull request #291](https://github.com/yonahforst/react-native-permissions/pull/291) for feedbacks.

## Support

| version | react-native version |
| ------- | -------------------- |
| 2.0.0+  | 0.56.0+              |
| 1.1.1   | 0.40.0 - 0.52.2      |

## Setup

```bash
$ npm install --save react-native-permissions
# --- or ---
$ yarn add react-native-permissions
```

### iOS specific

To allow installation of the needed permission handlers for your project (and only them), `react-native-permissions` uses CocoaPods. Update the following line with your path to `node_modules/` and add it to your podfile:

```ruby
target 'YourAwesomeProject' do

  # …

  pod 'RNPermissions', :path => '../node_modules/react-native-permissions', :subspecs => [
    'Core',
    ## Uncomment needed permissions
    # 'BluetoothPeripheral',
    # 'Calendars',
    # 'Camera',
    # 'Contacts',
    # 'FaceID',
    # 'LocationAlways',
    # 'LocationWhenInUse',
    # 'MediaLibrary',
    # 'Microphone',
    # 'Motion',
    # 'Notifications',
    # 'PhotoLibrary',
    # 'Reminders',
    # 'Siri',
    # 'SpeechRecognition',
    # 'StoreKit',
  ]

end
```

### Android specific

1.  Add the following lines to `android/settings.gradle`:

```gradle
include ':react-native-permissions'
project(':react-native-permissions').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-permissions/android')
```

2.  Add the compile line to the dependencies in `android/app/build.gradle`:

```gradle
dependencies {
  // ...
  implementation project(':react-native-permissions')
}
```

3.  Add the import and link the package in `MainApplication.java`:

```java
import com.yonahforst.rnpermissions.RNPermissionsPackage; // <-- Add the import

public class MainApplication extends Application implements ReactApplication {

  // …

  @Override
  protected List<ReactPackage> getPackages() {
    return Arrays.<ReactPackage>asList(
      new MainReactPackage(),
      // …
      new RNPermissionsPackage() // <-- Add it to the packages list
    );
  }

  // …
}
```

_📌 Don't forget to add permissions to `AndroidManifest.xml` for android and
`Info.plist` for iOS (Xcode >= 8)._

## API (subject to changes)

### Permissions statuses

Promises resolve into one of these statuses:

| Return value              | Notes                                                              |
| ------------------------- | ------------------------------------------------------------------ |
| `RESULTS.UNAVAILABLE`     | This feature is not available on this device.                      |
| `RESULTS.GRANTED`         | The permission is granted.                                         |
| `RESULTS.DENIED`          | The permission has not been requested / is denied but requestable. |
| `RESULTS.NEVER_ASK_AGAIN` | The permission is not requestable anymore.                         |

### Supported permissions

```js
import { ANDROID_PERMISSIONS, IOS_PERMISSIONS } from "react-native-permissions";

// For Android

// same as PermissionsAndroid
ANDROID_PERMISSIONS.READ_CALENDAR;
ANDROID_PERMISSIONS.WRITE_CALENDAR;
ANDROID_PERMISSIONS.CAMERA;
ANDROID_PERMISSIONS.READ_CONTACTS;
ANDROID_PERMISSIONS.WRITE_CONTACTS;
ANDROID_PERMISSIONS.GET_ACCOUNTS;
ANDROID_PERMISSIONS.ACCESS_FINE_LOCATION;
ANDROID_PERMISSIONS.ACCESS_COARSE_LOCATION;
ANDROID_PERMISSIONS.RECORD_AUDIO;
ANDROID_PERMISSIONS.READ_PHONE_STATE;
ANDROID_PERMISSIONS.CALL_PHONE;
ANDROID_PERMISSIONS.READ_CALL_LOG;
ANDROID_PERMISSIONS.WRITE_CALL_LOG;
ANDROID_PERMISSIONS.ADD_VOICEMAIL;
ANDROID_PERMISSIONS.USE_SIP;
ANDROID_PERMISSIONS.PROCESS_OUTGOING_CALLS;
ANDROID_PERMISSIONS.BODY_SENSORS;
ANDROID_PERMISSIONS.SEND_SMS;
ANDROID_PERMISSIONS.RECEIVE_SMS;
ANDROID_PERMISSIONS.READ_SMS;
ANDROID_PERMISSIONS.RECEIVE_WAP_PUSH;
ANDROID_PERMISSIONS.RECEIVE_MMS;
ANDROID_PERMISSIONS.READ_EXTERNAL_STORAGE;
ANDROID_PERMISSIONS.WRITE_EXTERNAL_STORAGE;

// new ones
ANDROID_PERMISSIONS.ANSWER_PHONE_CALLS;
ANDROID_PERMISSIONS.ACCEPT_HANDOVER;
ANDROID_PERMISSIONS.READ_PHONE_NUMBERS;

// For iOS

IOS_PERMISSIONS.BLUETOOTH_PERIPHERAL;
IOS_PERMISSIONS.CALENDARS;
IOS_PERMISSIONS.CAMERA;
IOS_PERMISSIONS.CONTACTS;
IOS_PERMISSIONS.FACE_ID;
IOS_PERMISSIONS.LOCATION_ALWAYS;
IOS_PERMISSIONS.LOCATION_WHEN_IN_USE;
IOS_PERMISSIONS.MEDIA_LIBRARY;
IOS_PERMISSIONS.MICROPHONE;
IOS_PERMISSIONS.MOTION;
IOS_PERMISSIONS.NOTIFICATIONS;
IOS_PERMISSIONS.PHOTO_LIBRARY;
IOS_PERMISSIONS.REMINDERS;
IOS_PERMISSIONS.SIRI;
IOS_PERMISSIONS.SPEECH_RECOGNITION;
IOS_PERMISSIONS.STOREKIT;
```

### Methods

_types used in usage examples_

```ts
type Permission = keyof ANDROID_PERMISSIONS | keyof IOS_PERMISSIONS;

type PermissionStatus =
  | "granted"
  | "denied"
  | "never_ask_again"
  | "unavailable";
```

#### check()

Check one permission status.

#### Method type

```ts
function check(permission: Permission): Promise<PermissionStatus>;
```

#### Usage example

```js
import { check, IOS_PERMISSIONS, RESULTS } from "react-native-permissions";

check(RNPermissions.IOS_PERMISSIONS.LOCATION_ALWAYS).then(result => {
  switch (result) {
    case RESULTS.UNAVAILABLE:
      console.log("the feature is not available on this device");
      break;
    case RESULTS.GRANTED:
      console.log("permission is granted");
      break;
    case RESULTS.DENIED:
      console.log("permission is denied, but requestable");
      break;
    case RESULTS.NEVER_ASK_AGAIN:
      console.log("permission is denied and not requestable");
      break;
  }
});
```

---

#### checkMultiple()

Check multiples permissions.

#### Method type

```ts
function checkMultiple<P: Permission>(permissions: P[]): Promise<{ [permission: P]: PermissionStatus }>;
```

#### Usage example

```js
import { checkMultiple, IOS_PERMISSIONS } from "react-native-permissions";

checkMultiple([
  IOS_PERMISSIONS.LOCATION_ALWAYS,
  IOS_PERMISSIONS.MEDIA_LIBRARY,
]).then(results => {
  // results.LOCATION_ALWAYS
  // results.MEDIA_LIBRARY
});
```

---

#### request()

Request one permission.

#### Method type

```ts
type NotificationOption =
  | "badge"
  | "sound"
  | "alert"
  | "carPlay"
  | "criticalAlert"
  | "provisional";

type Rationale = {
  title: string;
  message: string;
  buttonPositive: string;
  buttonNegative?: string;
  buttonNeutral?: string;
};

function request(
  permission: string,
  config: {
    notificationOptions?: NotificationOption[];
    rationale?: Rationale;
  } = {},
): Promise<PermissionStatus>;
```

#### Usage example

```js
import { request, IOS_PERMISSIONS } from "react-native-permissions";

request(IOS_PERMISSIONS.LOCATION_ALWAYS).then(result => {
  // …
});
```

---

#### requestMultiple()

Request multiples permissions.

#### Method type

```ts
function requestMultiple<P: Permission>(permissions: P[]): Promise<{ [permission: P]: PermissionStatus }>;
```

#### Usage example

```js
import { requestMultiple, IOS_PERMISSIONS } from "react-native-permissions";

requestMultiple([
  IOS_PERMISSIONS.LOCATION_ALWAYS,
  IOS_PERMISSIONS.MEDIA_LIBRARY,
]).then(results => {
  // results.LOCATION_ALWAYS
  // results.MEDIA_LIBRARY
});
```

---

#### openSettings()

Open application settings.

#### Method type

```ts
function openSettings(): Promise<boolean>;
```

#### Usage example

```js
import { openSettings } from "react-native-permissions";

openSettings().catch(() => console.warn("cannot open settings");
```

## 🍎  iOS Notes

- Permission type `BLUETOOTH_PERIPHERAL` represents the status of the `CBPeripheralManager`.
- If `notificationOptions` config array is omitted on `NOTIFICATIONS` request, it will request `alert`, `badge` and `sound`.
