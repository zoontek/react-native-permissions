# ☝🏼 React Native Permissions

[![npm version](https://badge.fury.io/js/react-native-permissions.svg)](https://badge.fury.io/js/react-native-permissions)
[![npm](https://img.shields.io/npm/dt/react-native-permissions.svg)](https://www.npmjs.org/package/react-native-permissions)
![Platform - Android and iOS](https://img.shields.io/badge/platform-Android%20%7C%20iOS-yellow.svg)
![MIT](https://img.shields.io/dub/l/vibe-d.svg)
[![styled with prettier](https://img.shields.io/badge/styled_with-prettier-ff69b4.svg)](https://github.com/prettier/prettier)

Check and request user permissions in React Native

## Support

| version | react-native version |
| ------- | -------------------- |
| 2.0.0+  | 0.60.0+              |
| 1.1.1   | 0.40.0 - 0.52.2      |

For 2.0.0 with 0.59-, you can use [`jetify -r`](https://github.com/mikehardy/jetifier/blob/master/README.md#to-reverse-jetify--convert-node_modules-dependencies-to-support-libraries)

## Setup

```bash
$ npm install --save react-native-permissions@next
# --- or ---
$ yarn add react-native-permissions@next
```

### iOS

By default no permission handler is installed. Add update your Podfile with the ones you want, then run `pod install`.

```ruby
target 'YourAwesomeProject' do

  # …

  permissions_path = '../node_modules/react-native-permissions/ios'

  pod 'Permission-BluetoothPeripheral', :path => "#{permissions_path}/BluetoothPeripheral.podspec"
  pod 'Permission-Calendars', :path => "#{permissions_path}/Calendars.podspec"
  pod 'Permission-Camera', :path => "#{permissions_path}/Camera.podspec"
  pod 'Permission-Contacts', :path => "#{permissions_path}/Contacts.podspec"
  pod 'Permission-FaceID', :path => "#{permissions_path}/FaceID.podspec"
  pod 'Permission-LocationAlways', :path => "#{permissions_path}/LocationAlways.podspec"
  pod 'Permission-LocationWhenInUse', :path => "#{permissions_path}/LocationWhenInUse.podspec"
  pod 'Permission-MediaLibrary', :path => "#{permissions_path}/MediaLibrary.podspec"
  pod 'Permission-Microphone', :path => "#{permissions_path}/Microphone.podspec"
  pod 'Permission-Motion', :path => "#{permissions_path}/Motion.podspec"
  pod 'Permission-Notifications', :path => "#{permissions_path}/Notifications.podspec"
  pod 'Permission-PhotoLibrary', :path => "#{permissions_path}/PhotoLibrary.podspec"
  pod 'Permission-Reminders', :path => "#{permissions_path}/Reminders.podspec"
  pod 'Permission-Siri', :path => "#{permissions_path}/Siri.podspec"
  pod 'Permission-SpeechRecognition', :path => "#{permissions_path}/SpeechRecognition.podspec"
  pod 'Permission-StoreKit', :path => "#{permissions_path}/StoreKit.podspec"

end
```

_⚠️ Don't forget to add permissions to `AndroidManifest.xml` for android and
`Info.plist` for iOS._

## 🆘 Manual linking

Because this package targets React Native 0.60+, you will probably don't need to link it. Otherwise if you follow all the previous steps and it still doesn't work, try to link this library manually:

#### iOS

Add this line to your `ios/Podfile` file, then run `pod install`.

```bash
target 'YourAwesomeProject' do
  # …
  pod 'RNPermissions', :path => '../node_modules/react-native-permissions'
end
```

### Android

1. Add the following lines to `android/settings.gradle`:

```gradle
include ':react-native-permissions'
project(':react-native-permissions').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-permissions/android')
```

2. Add the implementation line to the dependencies in `android/app/build.gradle`:

```gradle
dependencies {
  // ...
  implementation project(':react-native-permissions')
}
```

3. Add the import and link the package in `MainApplication.java`:

```java
import com.reactnativecommunity.rnpermissions.RNPermissionsPackage; // <- add the RNPermissionsPackage import

public class MainApplication extends Application implements ReactApplication {

  // …

  @Override
  protected List<ReactPackage> getPackages() {
    @SuppressWarnings("UnnecessaryLocalVariable")
    List<ReactPackage> packages = new PackageList(this).getPackages();
    // …
    packages.add(new RNPermissionsPackage());
    return packages;
  }

  // …
}
```

## API

### Permissions statuses

Promises resolve into one of these statuses:

| Return value          | Notes                                                             |
| --------------------- | ----------------------------------------------------------------- |
| `RESULTS.UNAVAILABLE` | This feature is not available (on this device / in this context)  |
| `RESULTS.DENIED`      | The permission has not been requested / is denied but requestable |
| `RESULTS.GRANTED`     | The permission is granted                                         |
| `RESULTS.BLOCKED`     | The permission is denied and not requestable anymore              |

### Supported permissions

```js
import {PERMISSIONS} from 'react-native-permissions';

// Android permissions

PERMISSIONS.ANDROID.ACCEPT_HANDOVER;
PERMISSIONS.ANDROID.ACCESS_BACKGROUND_LOCATION;
PERMISSIONS.ANDROID.ACCESS_COARSE_LOCATION;
PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION;
PERMISSIONS.ANDROID.ACTIVITY_RECOGNITION;
PERMISSIONS.ANDROID.ADD_VOICEMAIL;
PERMISSIONS.ANDROID.ANSWER_PHONE_CALLS;
PERMISSIONS.ANDROID.BODY_SENSORS;
PERMISSIONS.ANDROID.CALL_PHONE;
PERMISSIONS.ANDROID.CAMERA;
PERMISSIONS.ANDROID.GET_ACCOUNTS;
PERMISSIONS.ANDROID.PROCESS_OUTGOING_CALLS;
PERMISSIONS.ANDROID.READ_CALENDAR;
PERMISSIONS.ANDROID.READ_CALL_LOG;
PERMISSIONS.ANDROID.READ_CONTACTS;
PERMISSIONS.ANDROID.READ_EXTERNAL_STORAGE;
PERMISSIONS.ANDROID.READ_PHONE_NUMBERS;
PERMISSIONS.ANDROID.READ_PHONE_STATE;
PERMISSIONS.ANDROID.READ_SMS;
PERMISSIONS.ANDROID.RECEIVE_MMS;
PERMISSIONS.ANDROID.RECEIVE_SMS;
PERMISSIONS.ANDROID.RECEIVE_WAP_PUSH;
PERMISSIONS.ANDROID.RECORD_AUDIO;
PERMISSIONS.ANDROID.SEND_SMS;
PERMISSIONS.ANDROID.USE_SIP;
PERMISSIONS.ANDROID.WRITE_CALENDAR;
PERMISSIONS.ANDROID.WRITE_CALL_LOG;
PERMISSIONS.ANDROID.WRITE_CONTACTS;
PERMISSIONS.ANDROID.WRITE_EXTERNAL_STORAGE;

// iOS permissions

PERMISSIONS.IOS.BLUETOOTH_PERIPHERAL;
PERMISSIONS.IOS.CALENDARS;
PERMISSIONS.IOS.CAMERA;
PERMISSIONS.IOS.CONTACTS;
PERMISSIONS.IOS.FACE_ID;
PERMISSIONS.IOS.LOCATION_ALWAYS;
PERMISSIONS.IOS.LOCATION_WHEN_IN_USE;
PERMISSIONS.IOS.MEDIA_LIBRARY;
PERMISSIONS.IOS.MICROPHONE;
PERMISSIONS.IOS.MOTION;
PERMISSIONS.IOS.PHOTO_LIBRARY;
PERMISSIONS.IOS.REMINDERS;
PERMISSIONS.IOS.SIRI;
PERMISSIONS.IOS.SPEECH_RECOGNITION;
PERMISSIONS.IOS.STOREKIT;
```

### Methods

_types used in usage examples_

```ts
type PermissionStatus = 'unavailable' | 'denied' | 'blocked' | 'granted';
```

#### check

Check one permission status.

```ts
function check(permission: string): Promise<PermissionStatus>;
```

```js
import {check, PERMISSIONS, RESULTS} from 'react-native-permissions';

check(PERMISSIONS.IOS.LOCATION_ALWAYS)
  .then(result => {
    switch (result) {
      case RESULTS.UNAVAILABLE:
        console.log('the feature is not available');
        break;
      case RESULTS.GRANTED:
        console.log('permission is granted');
        break;
      case RESULTS.DENIED:
        console.log('permission is denied and / or requestable');
        break;
      case RESULTS.BLOCKED:
        console.log('permission is denied and not requestable');
        break;
    }
  })
  .catch(error => {
    // …
  });
```

---

#### request

Request one permission.

```ts
type Rationale = {
  title: string;
  message: string;
  buttonPositive?: string;
  buttonNegative?: string;
  buttonNeutral?: string;
};

function request(
  permission: string,
  rationale?: Rationale,
): Promise<PermissionStatus>;
```

```js
import {request, PERMISSIONS} from 'react-native-permissions';

request(PERMISSIONS.IOS.LOCATION_ALWAYS).then(result => {
  // …
});
```

---

#### checkNotifications

Check notifications permission status and get settings values.

```ts
interface NotificationSettings {
  // properties only availables on iOS
  // unavaible settings will not be included in the response object
  alert?: boolean;
  badge?: boolean;
  sound?: boolean;
  lockScreen?: boolean;
  carPlay?: boolean;
  critical?: boolean;
}

function checkNotifications(): Promise<{
  status: PermissionStatus;
  settings: NotificationSettings;
}>;
```

```js
import {checkNotifications} from 'react-native-permissions';

checkNotifications().then(({status, settings}) => {
  // …
});
```

---

#### requestNotifications

Request notifications permission status and get settings values.

```ts
// only used on iOS
type NotificationOption =
  | 'alert'
  | 'badge'
  | 'sound'
  | 'criticalAlert'
  | 'carPlay'
  | 'provisional';

interface NotificationSettings {
  // properties only availables on iOS
  // unavaible settings will not be included in the response object
  alert?: boolean;
  badge?: boolean;
  sound?: boolean;
  lockScreen?: boolean;
  carPlay?: boolean;
  critical?: boolean;
}

function requestNotifications(
  options: NotificationOption[],
): Promise<{
  status: PermissionStatus;
  settings: NotificationSettings;
}>;
```

```js
import {requestNotifications} from 'react-native-permissions';

requestNotifications(['alert', 'sound']).then(({status, settings}) => {
  // …
});
```

---

#### openSettings

Open application settings.

```ts
function openSettings(): Promise<void>;
```

```js
import {openSettings} from 'react-native-permissions';

openSettings().catch(() => console.warn('cannot open settings'));
```
