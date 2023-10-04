# ☝🏼 react-native-permissions

An unified permissions API for React Native on iOS, Android and Windows.<br>
(For Windows only builds 18362 and later are supported)

[![mit licence](https://img.shields.io/dub/l/vibe-d.svg?style=for-the-badge)](https://github.com/zoontek/react-native-permissions/blob/main/LICENSE)
[![npm version](https://img.shields.io/npm/v/react-native-permissions?style=for-the-badge)](https://www.npmjs.org/package/react-native-permissions)
[![npm downloads](https://img.shields.io/npm/dt/react-native-permissions.svg?label=downloads&style=for-the-badge)](https://www.npmjs.org/package/react-native-permissions)
<br />
[![platform - android](https://img.shields.io/badge/platform-Android-3ddc84.svg?logo=android&style=for-the-badge)](https://www.android.com)
[![platform - ios](https://img.shields.io/badge/platform-iOS-000.svg?logo=apple&style=for-the-badge)](https://developer.apple.com/ios)
[![platform - windows](https://img.shields.io/badge/platform-Windows-0067b8.svg?logo=windows&style=for-the-badge)](https://www.microsoft.com/en-us/windows)

## Support

This library follows the React Native [releases support policy](https://github.com/reactwg/react-native-releases#releases-support-policy).<br>
It is supporting the **latest version**, and the **two previous minor series**.

## Setup

```bash
$ npm install --save react-native-permissions
# --- or ---
$ yarn add react-native-permissions
```

### iOS

1. By default, no permissions are setuped. So first, require the `setup` script in your `Podfile`:

```diff
# with react-native >= 0.72
- # Resolve react_native_pods.rb with node to allow for hoisting
- require Pod::Executable.execute_command('node', ['-p',
-   'require.resolve(
-     "react-native/scripts/react_native_pods.rb",
-     {paths: [process.argv[1]]},
-   )', __dir__]).strip

+ def node_require(script)
+   # Resolve script with node to allow for hoisting
+   require Pod::Executable.execute_command('node', ['-p',
+     "require.resolve(
+       '#{script}',
+       {paths: [process.argv[1]]},
+     )", __dir__]).strip
+ end

+ node_require('react-native/scripts/react_native_pods.rb')
+ node_require('react-native-permissions/scripts/setup.rb')
```

```diff
# with react-native < 0.72
require_relative '../node_modules/react-native/scripts/react_native_pods'
require_relative '../node_modules/@react-native-community/cli-platform-ios/native_modules'
+ require_relative '../node_modules/react-native-permissions/scripts/setup'
```

2. Then in the same file, add a `setup_permissions` call with the wanted permissions:

```ruby
# …

platform :ios, min_ios_version_supported
prepare_react_native_project!

# ⬇️ uncomment wanted permissions
setup_permissions([
  # 'AppTrackingTransparency',
  # 'BluetoothPeripheral',
  # 'Calendars',
  # 'Camera',
  # 'Contacts',
  # 'FaceID',
  # 'LocationAccuracy',
  # 'LocationAlways',
  # 'LocationWhenInUse',
  # 'MediaLibrary',
  # 'Microphone',
  # 'Motion',
  # 'Notifications',
  # 'PhotoLibrary',
  # 'PhotoLibraryAddOnly',
  # 'Reminders',
  # 'Siri',
  # 'SpeechRecognition',
  # 'StoreKit',
])

# …
```

3. Then execute `pod install` _(📌  Note that it must be re-executed each time you update this config)_.
4. Finally, update your `Info.plist` with the wanted permissions usage descriptions:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>

  <!-- 🚨 Keep only the permissions used in your app 🚨 -->

  <key>NSAppleMusicUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSBluetoothAlwaysUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSBluetoothPeripheralUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSCalendarsUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSCameraUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSContactsUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSFaceIDUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSLocationTemporaryUsageDescriptionDictionary</key>
  <dict>
    <key>YOUR-PURPOSE-KEY</key>
    <string>YOUR TEXT</string>
  </dict>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSMotionUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSPhotoLibraryAddUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSRemindersUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSSpeechRecognitionUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSSiriUsageDescription</key>
  <string>YOUR TEXT</string>
  <key>NSUserTrackingUsageDescription</key>
  <string>YOUR TEXT</string>

  <!-- … -->

</dict>
</plist>
```

### Android

Add all wanted permissions to your app `android/app/src/main/AndroidManifest.xml` file:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

  <!-- 🚨 Keep only the permissions used in your app 🚨 -->

  <uses-permission android:name="android.permission.ACCEPT_HANDOVER" />
  <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
  <uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />
  <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
  <uses-permission android:name="com.android.voicemail.permission.ADD_VOICEMAIL" />
  <uses-permission android:name="android.permission.ANSWER_PHONE_CALLS" />
  <uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />
  <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
  <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
  <uses-permission android:name="android.permission.BODY_SENSORS" />
  <uses-permission android:name="android.permission.BODY_SENSORS_BACKGROUND" />
  <uses-permission android:name="android.permission.CALL_PHONE" />
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.GET_ACCOUNTS" />
  <uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  <uses-permission android:name="android.permission.PROCESS_OUTGOING_CALLS" />
  <uses-permission android:name="android.permission.READ_CALENDAR" />
  <uses-permission android:name="android.permission.READ_CALL_LOG" />
  <uses-permission android:name="android.permission.READ_CONTACTS" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
  <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
  <uses-permission android:name="android.permission.READ_PHONE_NUMBERS" />
  <uses-permission android:name="android.permission.READ_PHONE_STATE" />
  <uses-permission android:name="android.permission.READ_SMS" />
  <uses-permission android:name="android.permission.RECEIVE_MMS" />
  <uses-permission android:name="android.permission.RECEIVE_SMS" />
  <uses-permission android:name="android.permission.RECEIVE_WAP_PUSH" />
  <uses-permission android:name="android.permission.RECORD_AUDIO" />
  <uses-permission android:name="android.permission.SEND_SMS" />
  <uses-permission android:name="android.permission.USE_SIP" />
  <uses-permission android:name="android.permission.UWB_RANGING" />
  <uses-permission android:name="android.permission.WRITE_CALENDAR" />
  <uses-permission android:name="android.permission.WRITE_CALL_LOG" />
  <uses-permission android:name="android.permission.WRITE_CONTACTS" />
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

  <!-- … -->

</manifest>
```

### Windows

Open the project solution file from the `windows` folder. In the app project open `Package.appxmanifest` file. From there you can select which capabilites you want your app to support.

## 🆘 Manual linking

Because this package targets recent React Native versions, you probably don't need to link it manually. But if you have a special case, follow these additional instructions:

<details>
  <summary><b>👀 See manual linking instructions</b></summary>

### iOS

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
import com.zoontek.rnpermissions.RNPermissionsPackage; // <- add the RNPermissionsPackage import

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

### Windows

1. In `windows/myapp.sln` add the `RNCConfig` project to your solution:

- Open the solution in Visual Studio 2019
- Right-click Solution icon in Solution Explorer > Add > Existing Project
- Select `node_modules\react-native-permissions\windows\RNPermissions\RNPermissions.vcxproj`

2. In `windows/myapp/myapp.vcxproj` ad a reference to `RNPermissions` to your main application project. From Visual Studio 2019:

- Right-click main application project > Add > Reference...
- Check `RNPermissions` from Solution Projects.

3. In `pch.h` add `#include "winrt/RNPermissions.h"`.

4. In `app.cpp` add `PackageProviders().Append(winrt::RNPermissions::ReactPackageProvider());` before `InitializeComponent();`.

</details>

## Understanding permission flow

As permissions are not handled in the same way on iOS and Android, this library provides an abstraction over the two platforms' behaviors. To understand it a little better, take a look to these two flowcharts:

### iOS flow

```
   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ check(PERMISSIONS.IOS.CAMERA) ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                   │
       Is the feature available
           on this device ?
                   │           ╔════╗
                   ├───────────║ NO ║──────────────┐
                   │           ╚════╝              │
                ╔═════╗                            ▼
                ║ YES ║                 ┌─────────────────────┐
                ╚═════╝                 │ RESULTS.UNAVAILABLE │
                   │                    └─────────────────────┘
           Is the permission
             requestable ?
                   │           ╔════╗
                   ├───────────║ NO ║──────────────┐
                   │           ╚════╝              │
                ╔═════╗                            ▼
                ║ YES ║                  ┌───────────────────┐
                ╚═════╝                  │ RESULTS.BLOCKED / │
                   │                     │ RESULTS.LIMITED / │
                   │                     │  RESULTS.GRANTED  │
                   ▼                     └───────────────────┘
          ┌────────────────┐
          │ RESULTS.DENIED │
          └────────────────┘
                   │
                   ▼
  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ request(PERMISSIONS.IOS.CAMERA) ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                   │
         Does the user accept
            the request ?
                   │           ╔════╗
                   ├───────────║ NO ║──────────────┐
                   │           ╚════╝              │
                ╔═════╗                            ▼
                ║ YES ║                   ┌─────────────────┐
                ╚═════╝                   │ RESULTS.BLOCKED │
                   │                      └─────────────────┘
                   ▼
          ┌─────────────────┐
          │ RESULTS.GRANTED │
          └─────────────────┘
```

### Android flow

```
 ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
 ┃ check(PERMISSIONS.ANDROID.CAMERA) ┃
 ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                   │
       Is the feature available
           on this device ?
                   │           ╔════╗
                   ├───────────║ NO ║──────────────┐
                   │           ╚════╝              │
                ╔═════╗                            ▼
                ║ YES ║                 ┌─────────────────────┐
                ╚═════╝                 │ RESULTS.UNAVAILABLE │
                   │                    └─────────────────────┘
           Is the permission
           already granted ?
                   │           ╔═════╗
                   ├───────────║ YES ║─────────────┐
                   │           ╚═════╝             │
                ╔════╗                             ▼
                ║ NO ║                   ┌───────────────────┐
                ╚════╝                   │  RESULTS.GRANTED  │
                   │                     └───────────────────┘
                   ▼
          ┌────────────────┐
          │ RESULTS.DENIED │◀──────────────────────┐
          └────────────────┘                       │
                   │                               │
                   ▼                               │
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓         ╔═════╗
┃ request(PERMISSIONS.ANDROID.CAMERA) ┃         ║ YES ║
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛         ╚═════╝
                   │                               │
         Does the user accept                      │
            the request ?                          │
                   │           ╔════╗      Is the permission
                   ├───────────║ NO ║──── still requestable ?
                   │           ╚════╝              │
                ╔═════╗                         ╔════╗
                ║ YES ║                         ║ NO ║
                ╚═════╝                         ╚════╝
                   │                               │
                   ▼                               ▼
          ┌─────────────────┐             ┌─────────────────┐
          │ RESULTS.GRANTED │             │ RESULTS.BLOCKED │
          └─────────────────┘             └─────────────────┘
```

### Windows flow

```
   ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
   ┃ check(PERMISSIONS.WINDOWS.WEBCAM) ┃
   ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                     │
         Is the feature available
              on this device ?
                     │           ╔════╗
                     ├───────────║ NO ║──────────────┐
                     │           ╚════╝              │
                  ╔═════╗                            ▼
                  ║ YES ║                 ┌─────────────────────┐
                  ╚═════╝                 │ RESULTS.UNAVAILABLE │
                     │                    └─────────────────────┘
             Is the permission
               requestable ?
                     │           ╔════╗
                     ├───────────║ NO ║──────────────┐
                     │           ╚════╝              │
                  ╔═════╗                            ▼
                  ║ YES ║                  ┌───────────────────┐
                  ╚═════╝                  │ RESULTS.BLOCKED / │
                     │                     │  RESULTS.GRANTED  │
                     ▼                     └───────────────────┘
            ┌────────────────┐
            │ RESULTS.DENIED │
            └────────────────┘
                     │
                     ▼
  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
  ┃ request(PERMISSIONS.WINDOWS.WEBCAM) ┃
  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
                     │
           Does the user accept
              the request ?
                     │           ╔════╗
                     ├───────────║ NO ║──────────────┐
                     │           ╚════╝              │
                  ╔═════╗                            ▼
                  ║ YES ║                   ┌─────────────────┐
                  ╚═════╝                   │ RESULTS.BLOCKED │
                     │                      └─────────────────┘
                     ▼
            ┌─────────────────┐
            │ RESULTS.GRANTED │
            └─────────────────┘
```

## API

### Supported permissions

<details>
  <summary><b>Android permissions</b></summary>

```js
import {PERMISSIONS} from 'react-native-permissions';

PERMISSIONS.ANDROID.ACCEPT_HANDOVER;
PERMISSIONS.ANDROID.ACCESS_BACKGROUND_LOCATION;
PERMISSIONS.ANDROID.ACCESS_COARSE_LOCATION;
PERMISSIONS.ANDROID.ACCESS_FINE_LOCATION;
PERMISSIONS.ANDROID.ACCESS_MEDIA_LOCATION;
PERMISSIONS.ANDROID.ACTIVITY_RECOGNITION;
PERMISSIONS.ANDROID.ADD_VOICEMAIL;
PERMISSIONS.ANDROID.ANSWER_PHONE_CALLS;
PERMISSIONS.ANDROID.BLUETOOTH_ADVERTISE;
PERMISSIONS.ANDROID.BLUETOOTH_CONNECT;
PERMISSIONS.ANDROID.BLUETOOTH_SCAN;
PERMISSIONS.ANDROID.BODY_SENSORS;
PERMISSIONS.ANDROID.BODY_SENSORS_BACKGROUND;
PERMISSIONS.ANDROID.CALL_PHONE;
PERMISSIONS.ANDROID.CAMERA;
PERMISSIONS.ANDROID.GET_ACCOUNTS;
PERMISSIONS.ANDROID.NEARBY_WIFI_DEVICES;
PERMISSIONS.ANDROID.POST_NOTIFICATIONS;
PERMISSIONS.ANDROID.PROCESS_OUTGOING_CALLS;
PERMISSIONS.ANDROID.READ_CALENDAR;
PERMISSIONS.ANDROID.READ_CALL_LOG;
PERMISSIONS.ANDROID.READ_CONTACTS;
PERMISSIONS.ANDROID.READ_EXTERNAL_STORAGE;
PERMISSIONS.ANDROID.READ_MEDIA_AUDIO;
PERMISSIONS.ANDROID.READ_MEDIA_IMAGES;
PERMISSIONS.ANDROID.READ_MEDIA_VIDEO;
PERMISSIONS.ANDROID.READ_PHONE_NUMBERS;
PERMISSIONS.ANDROID.READ_PHONE_STATE;
PERMISSIONS.ANDROID.READ_SMS;
PERMISSIONS.ANDROID.RECEIVE_MMS;
PERMISSIONS.ANDROID.RECEIVE_SMS;
PERMISSIONS.ANDROID.RECEIVE_WAP_PUSH;
PERMISSIONS.ANDROID.RECORD_AUDIO;
PERMISSIONS.ANDROID.SEND_SMS;
PERMISSIONS.ANDROID.USE_SIP;
PERMISSIONS.ANDROID.UWB_RANGING;
PERMISSIONS.ANDROID.WRITE_CALENDAR;
PERMISSIONS.ANDROID.WRITE_CALL_LOG;
PERMISSIONS.ANDROID.WRITE_CONTACTS;
PERMISSIONS.ANDROID.WRITE_EXTERNAL_STORAGE;
```

</details>

<details>
  <summary><b>iOS permissions</b></summary>

```js
import {PERMISSIONS} from 'react-native-permissions';

PERMISSIONS.IOS.APP_TRACKING_TRANSPARENCY;
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
PERMISSIONS.IOS.PHOTO_LIBRARY_ADD_ONLY;
PERMISSIONS.IOS.REMINDERS;
PERMISSIONS.IOS.SIRI;
PERMISSIONS.IOS.SPEECH_RECOGNITION;
PERMISSIONS.IOS.STOREKIT;
```

</details>

<details>
  <summary><b>Windows permissions</b></summary>

```js
import {PERMISSIONS} from 'react-native-permissions';

PERMISSIONS.WINDOWS.ACCESSORY_MANAGER;
PERMISSIONS.WINDOWS.ACTIVITY;
PERMISSIONS.WINDOWS.ALLOW_ELEVATION;
PERMISSIONS.WINDOWS.ALL_APP_MODS;
PERMISSIONS.WINDOWS.ALL_JOYN;
PERMISSIONS.WINDOWS.APPOINTMENTS;
PERMISSIONS.WINDOWS.APPOINTMENTS_SYSTEM;
PERMISSIONS.WINDOWS.APP_BROADCAST_SERVICES;
PERMISSIONS.WINDOWS.APP_CAPTURE_SERVICES;
PERMISSIONS.WINDOWS.APP_CAPTURE_SETTINGS;
PERMISSIONS.WINDOWS.APP_DIAGNOSTICS;
PERMISSIONS.WINDOWS.APP_LICENSING;
PERMISSIONS.WINDOWS.AUDIO_DEVICE_CONFIGURATION;
PERMISSIONS.WINDOWS.BACKGROUND_MEDIA_PLAYBACK;
PERMISSIONS.WINDOWS.BACKGROUND_MEDIA_RECORDING;
PERMISSIONS.WINDOWS.BACKGROUND_SPATIAL_PERCEPTION;
PERMISSIONS.WINDOWS.BACKGROUND_VOIP;
PERMISSIONS.WINDOWS.BLOCKED_CHAT_MESSAGES;
PERMISSIONS.WINDOWS.BLUETOOTH;
PERMISSIONS.WINDOWS.BROAD_FILE_SYSTEM_ACCESS;
PERMISSIONS.WINDOWS.CAMERA_PROCESSING_EXTENSION;
PERMISSIONS.WINDOWS.CELLULAR_DEVICE_CONTROL;
PERMISSIONS.WINDOWS.CELLULAR_DEVICE_IDENTITY;
PERMISSIONS.WINDOWS.CELLULAR_MESSAGING;
PERMISSIONS.WINDOWS.CHAT_SYSTEM;
PERMISSIONS.WINDOWS.CODE_GENERATION;
PERMISSIONS.WINDOWS.CONFIRM_APP_CLOSE;
PERMISSIONS.WINDOWS.CONTACTS;
PERMISSIONS.WINDOWS.CONTACTS_SYSTEM;
PERMISSIONS.WINDOWS.CORTANA_PERMISSIONS;
PERMISSIONS.WINDOWS.CORTANA_SPEECH_ACCESSORY;
PERMISSIONS.WINDOWS.CUSTOM_INSTALL_ACTIONS;
PERMISSIONS.WINDOWS.DEVELOPMENT_MODE_NETWORK;
PERMISSIONS.WINDOWS.DEVICE_MANAGEMENT_DM_ACCOUNT;
PERMISSIONS.WINDOWS.DEVICE_MANAGEMENT_EMAIL_ACCOUNT;
PERMISSIONS.WINDOWS.DEVICE_MANAGEMENT_FOUNDATION;
PERMISSIONS.WINDOWS.DEVICE_MANAGEMENT_WAP_SECURITY_POLICIES;
PERMISSIONS.WINDOWS.DEVICE_PORTAL_PROVIDER;
PERMISSIONS.WINDOWS.DEVICE_UNLOCK;
PERMISSIONS.WINDOWS.DOCUMENTS_LIBRARY;
PERMISSIONS.WINDOWS.DUAL_SIM_TILES;
PERMISSIONS.WINDOWS.EMAIL;
PERMISSIONS.WINDOWS.EMAIL_SYSTEM;
PERMISSIONS.WINDOWS.ENTERPRISE_AUTHENTICATION;
PERMISSIONS.WINDOWS.ENTERPRISE_CLOUD_S_S_O;
PERMISSIONS.WINDOWS.ENTERPRISE_DATA_POLICY;
PERMISSIONS.WINDOWS.ENTERPRISE_DEVICE_LOCKDOWN;
PERMISSIONS.WINDOWS.EXPANDED_RESOURCES;
PERMISSIONS.WINDOWS.EXTENDED_BACKGROUND_TASK_TIME;
PERMISSIONS.WINDOWS.EXTENDED_EXECUTION_BACKGROUND_AUDIO;
PERMISSIONS.WINDOWS.EXTENDED_EXECUTION_CRITICAL;
PERMISSIONS.WINDOWS.EXTENDED_EXECUTION_UNCONSTRAINED;
PERMISSIONS.WINDOWS.FIRST_SIGN_IN_SETTINGS;
PERMISSIONS.WINDOWS.GAME_BAR_SERVICES;
PERMISSIONS.WINDOWS.GAME_LIST;
PERMISSIONS.WINDOWS.GAME_MONITOR;
PERMISSIONS.WINDOWS.GAZE_INPUT;
PERMISSIONS.WINDOWS.GLOBAL_MEDIA_CONTROL;
PERMISSIONS.WINDOWS.HUMANINTERFACEDEVICE;
PERMISSIONS.WINDOWS.INPUT_FOREGROUND_OBSERVATION;
PERMISSIONS.WINDOWS.INPUT_INJECTION_BROKERED;
PERMISSIONS.WINDOWS.INPUT_OBSERVATION;
PERMISSIONS.WINDOWS.INPUT_SUPPRESSION;
PERMISSIONS.WINDOWS.INTERNET_CLIENT;
PERMISSIONS.WINDOWS.INTERNET_CLIENT_SERVER;
PERMISSIONS.WINDOWS.INTEROP_SERVICES;
PERMISSIONS.WINDOWS.IOT;
PERMISSIONS.WINDOWS.LOCAL_SYSTEM_SERVICES;
PERMISSIONS.WINDOWS.LOCATION;
PERMISSIONS.WINDOWS.LOCATION_HISTORY;
PERMISSIONS.WINDOWS.LOCATION_SYSTEM;
PERMISSIONS.WINDOWS.LOW_LEVEL;
PERMISSIONS.WINDOWS.LOW_LEVEL_DEVICES;
PERMISSIONS.WINDOWS.MICROPHONE;
PERMISSIONS.WINDOWS.MOBILE;
PERMISSIONS.WINDOWS.MODIFIABLE_APP;
PERMISSIONS.WINDOWS.MUSIC_LIBRARY;
PERMISSIONS.WINDOWS.NETWORKING_VPN_PROVIDER;
PERMISSIONS.WINDOWS.NETWORK_CONNECTION_MANAGER_PROVISIONING;
PERMISSIONS.WINDOWS.NETWORK_DATA_PLAN_PROVISIONING;
PERMISSIONS.WINDOWS.NETWORK_DATA_USAGE_MANAGEMENT;
PERMISSIONS.WINDOWS.OEM_DEPLOYMENT;
PERMISSIONS.WINDOWS.OEM_PUBLIC_DIRECTORY;
PERMISSIONS.WINDOWS.ONE_PROCESS_VOIP;
PERMISSIONS.WINDOWS.OPTICAL;
PERMISSIONS.WINDOWS.PACKAGED_SERVICES;
PERMISSIONS.WINDOWS.PACKAGES_SERVICES;
PERMISSIONS.WINDOWS.PACKAGE_MANAGEMENT;
PERMISSIONS.WINDOWS.PACKAGE_POLICY_SYSTEM;
PERMISSIONS.WINDOWS.PACKAGE_QUERY;
PERMISSIONS.WINDOWS.PACKAGE_WRITE_REDIRECTION_COMPATIBILITY_SHIM;
PERMISSIONS.WINDOWS.PHONE_CALL;
PERMISSIONS.WINDOWS.PHONE_CALL_HISTORY;
PERMISSIONS.WINDOWS.PHONE_CALL_HISTORY_SYSTEM;
PERMISSIONS.WINDOWS.PHONE_LINE_TRANSPORT_MANAGEMENT;
PERMISSIONS.WINDOWS.PICTURES_LIBRARY;
PERMISSIONS.WINDOWS.POINT_OF_SERVICE;
PERMISSIONS.WINDOWS.PREVIEW_INK_WORKSPACE;
PERMISSIONS.WINDOWS.PREVIEW_PEN_WORKSPACE;
PERMISSIONS.WINDOWS.PREVIEW_STORE;
PERMISSIONS.WINDOWS.PREVIEW_UI_COMPOSITION;
PERMISSIONS.WINDOWS.PRIVATE_NETWORK_CLIENT_SERVER;
PERMISSIONS.WINDOWS.PROTECTED_APP;
PERMISSIONS.WINDOWS.PROXIMITY;
PERMISSIONS.WINDOWS.RADIOS;
PERMISSIONS.WINDOWS.RECORDED_CALLS_FOLDER;
PERMISSIONS.WINDOWS.REMOTE_PASSPORT_AUTHENTICATION;
PERMISSIONS.WINDOWS.REMOTE_SYSTEM;
PERMISSIONS.WINDOWS.REMOVABLE_STORAGE;
PERMISSIONS.WINDOWS.RESCAP;
PERMISSIONS.WINDOWS.RUN_FULL_TRUST;
PERMISSIONS.WINDOWS.SCREEN_DUPLICATION;
PERMISSIONS.WINDOWS.SECONDARY_AUTHENTICATION_FACTOR;
PERMISSIONS.WINDOWS.SECURE_ASSESSMENT;
PERMISSIONS.WINDOWS.SERIALCOMMUNICATION;
PERMISSIONS.WINDOWS.SHARED_USER_CERTIFICATES;
PERMISSIONS.WINDOWS.SLAPI_QUERY_LICENSE_VALUE;
PERMISSIONS.WINDOWS.SMBIOS;
PERMISSIONS.WINDOWS.SMS_SEND;
PERMISSIONS.WINDOWS.SPATIAL_PERCEPTION;
PERMISSIONS.WINDOWS.START_SCREEN_MANAGEMENT;
PERMISSIONS.WINDOWS.STORE_LICENSE_MANAGEMENT;
PERMISSIONS.WINDOWS.SYSTEM_MANAGEMENT;
PERMISSIONS.WINDOWS.TARGETED_CONTENT;
PERMISSIONS.WINDOWS.TEAM_EDITION_DEVICE_CREDENTIAL;
PERMISSIONS.WINDOWS.TEAM_EDITION_EXPERIENCE;
PERMISSIONS.WINDOWS.TEAM_EDITION_VIEW;
PERMISSIONS.WINDOWS.UAP;
PERMISSIONS.WINDOWS.UI_AUTOMATION;
PERMISSIONS.WINDOWS.UNVIRTUALIZED_RESOURCES;
PERMISSIONS.WINDOWS.USB;
PERMISSIONS.WINDOWS.USER_ACCOUNT_INFORMATION;
PERMISSIONS.WINDOWS.USER_DATA_ACCOUNTS_PROVIDER;
PERMISSIONS.WINDOWS.USER_DATA_SYSTEM;
PERMISSIONS.WINDOWS.USER_PRINCIPAL_NAME;
PERMISSIONS.WINDOWS.USER_SYSTEM_ID;
PERMISSIONS.WINDOWS.VIDEOS_LIBRARY;
PERMISSIONS.WINDOWS.VOIP_CALL;
PERMISSIONS.WINDOWS.WALLET_SYSTEM;
PERMISSIONS.WINDOWS.WEBCAM;
PERMISSIONS.WINDOWS.WIFI_CONTROL;
PERMISSIONS.WINDOWS.XBOX_ACCESSORY_MANAGEMENT;
```

</details>

### Permissions statuses

Permission checks and requests resolve into one of these statuses:

| Return value          | Notes                                                             |
| --------------------- | ----------------------------------------------------------------- |
| `RESULTS.UNAVAILABLE` | This feature is not available (on this device / in this context)  |
| `RESULTS.DENIED`      | The permission has not been requested / is denied but requestable |
| `RESULTS.GRANTED`     | The permission is granted                                         |
| `RESULTS.LIMITED`     | The permission is granted but with limitations                    |
| `RESULTS.BLOCKED`     | The permission is denied and not requestable anymore              |

### Methods

```ts
// type used in usage examples
type PermissionStatus = 'unavailable' | 'denied' | 'limited' | 'granted' | 'blocked';
```

#### check

Check one permission status.

_⚠️  Android will never return `blocked` after a `check`, you have to request the permission to get the info._

```ts
function check(permission: string): Promise<PermissionStatus>;
```

```js
import {check, PERMISSIONS, RESULTS} from 'react-native-permissions';

check(PERMISSIONS.IOS.LOCATION_ALWAYS)
  .then((result) => {
    switch (result) {
      case RESULTS.UNAVAILABLE:
        console.log('This feature is not available (on this device / in this context)');
        break;
      case RESULTS.DENIED:
        console.log('The permission has not been requested / is denied but requestable');
        break;
      case RESULTS.LIMITED:
        console.log('The permission is limited: some actions are possible');
        break;
      case RESULTS.GRANTED:
        console.log('The permission is granted');
        break;
      case RESULTS.BLOCKED:
        console.log('The permission is denied and not requestable anymore');
        break;
    }
  })
  .catch((error) => {
    // …
  });
```

---

#### request

Request one permission.

The `rationale` is only available and used on Android. It can be a native alert (a `Rationale` object) or a custom implementation (that resolves with a `boolean`).

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
  rationale?: Rationale | (() => Promise<boolean>),
): Promise<PermissionStatus>;
```

```js
import {request, PERMISSIONS} from 'react-native-permissions';

request(PERMISSIONS.IOS.LOCATION_ALWAYS).then((result) => {
  // …
});
```

---

#### checkNotifications

Check notifications permission status and get notifications settings values.

```ts
type NotificationSettings = {
  // properties only available on iOS
  // unavailable settings will not be included in the response object
  alert?: boolean;
  badge?: boolean;
  sound?: boolean;
  carPlay?: boolean;
  criticalAlert?: boolean;
  provisional?: boolean;
  providesAppSettings?: boolean;
  lockScreen?: boolean;
  notificationCenter?: boolean;
};

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

Request notifications permission status and get notifications settings values.

- You have to [target at least SDK 33](https://github.com/zoontek/react-native-permissions/releases/tag/3.5.0) to perform request on Android 13+. The permission is always granted for prior versions.
- You cannot request notifications permissions on Windows. Disabling / enabling them can only be done through the App Settings.

```ts
// only used on iOS
type NotificationOption =
  | 'alert'
  | 'badge'
  | 'sound'
  | 'criticalAlert'
  | 'carPlay'
  | 'provisional'
  | 'providesAppSettings';

type NotificationSettings = {
  // properties only available on iOS
  // unavailable settings will not be included in the response object
  alert?: boolean;
  badge?: boolean;
  sound?: boolean;
  carPlay?: boolean;
  criticalAlert?: boolean;
  provisional?: boolean;
  providesAppSettings?: boolean;
  lockScreen?: boolean;
  notificationCenter?: boolean;
};

function requestNotifications(options: NotificationOption[]): Promise<{
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

#### checkMultiple

Check multiples permissions in parallel.

_⚠️  Android will never return `blocked` after a `check`, you have to request the permission to get the info._

```ts
function checkMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>>;
```

```js
import {checkMultiple, PERMISSIONS} from 'react-native-permissions';

checkMultiple([PERMISSIONS.IOS.CAMERA, PERMISSIONS.IOS.FACE_ID]).then((statuses) => {
  console.log('Camera', statuses[PERMISSIONS.IOS.CAMERA]);
  console.log('FaceID', statuses[PERMISSIONS.IOS.FACE_ID]);
});
```

---

#### requestMultiple

Request multiple permissions in sequence.

```ts
function requestMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>>;
```

```js
import {requestMultiple, PERMISSIONS} from 'react-native-permissions';

requestMultiple([PERMISSIONS.IOS.CAMERA, PERMISSIONS.IOS.FACE_ID]).then((statuses) => {
  console.log('Camera', statuses[PERMISSIONS.IOS.CAMERA]);
  console.log('FaceID', statuses[PERMISSIONS.IOS.FACE_ID]);
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

---

#### openLimitedPhotoLibraryPicker (iOS 14+)

Open a picker to update the photo selection when `PhotoLibrary` permission is `limited`. This will reject if unsupported or if full permission is already `granted`.

```ts
function openLimitedPhotoLibraryPicker(): Promise<void>;
```

```js
import {openLimitedPhotoLibraryPicker} from 'react-native-permissions';

openLimitedPhotoLibraryPicker().catch(() => {
  console.warn('Cannot open photo library picker');
});
```

---

#### checkLocationAccuracy (iOS 14+)

When `LocationAlways` or `LocationWhenInUse` is `granted`, allow checking if the user share his precise location.

```ts
type LocationAccuracy = 'full' | 'reduced';

function checkLocationAccuracy(): Promise<LocationAccuracy>;
```

```js
import {checkLocationAccuracy} from 'react-native-permissions';

checkLocationAccuracy()
  .then((accuracy) => console.log(`Location accuracy is: ${accuracy}`))
  .catch(() => console.warn('Cannot check location accuracy'));
```

---

#### requestLocationAccuracy (iOS 14+)

When `LocationAlways` or `LocationWhenInUse` is `granted`, allow requesting the user for his precise location. Will resolve immediately if `full` accuracy is already authorized.

```ts
type LocationAccuracyOptions = {
  purposeKey: string;
};

type LocationAccuracy = 'full' | 'reduced';

function requestLocationAccuracy(options: LocationAccuracyOptions): Promise<LocationAccuracy>;
```

```js
import {requestLocationAccuracy} from 'react-native-permissions';

requestLocationAccuracy({purposeKey: 'YOUR-PURPOSE-KEY'})
  .then((accuracy) => console.log(`Location accuracy is: ${accuracy}`))
  .catch(() => console.warn('Cannot request location accuracy'));
```

### About iOS `LOCATION_ALWAYS` permission

If you are requesting `PERMISSIONS.IOS.LOCATION_ALWAYS`, there won't be a `Always Allow` button in the system dialog. Only `Allow Once`, `Allow While Using App` and `Don't Allow`. This is expected behaviour, check the [Apple Developer Docs](https://developer.apple.com/documentation/corelocation/cllocationmanager/1620551-requestalwaysauthorization#3578736).

When requesting `PERMISSIONS.IOS.LOCATION_ALWAYS`, if the user choose `Allow While Using App`, a provisional "always" status will be granted. The user will see `While Using` in the settings and later will be informed that your app is using the location in background. That looks like this:

![alt text](https://camo.githubusercontent.com/e8357168f4c8e754adfd940fc065520de838a21a80001839d5e740c18893ec67/68747470733a2f2f636d732e717a2e636f6d2f77702d636f6e74656e742f75706c6f6164732f323031392f30392f696f732d31332d6c6f636174696f6e732d7465736c612d31393230783938322e6a70673f7175616c6974793d37352673747269703d616c6c26773d3132303026683d3930302663726f703d31 'Screenshot')

Subsequently, if you are requesting `LOCATION_ALWAYS` permission, there is no need to request `LOCATION_WHEN_IN_USE`. If the user accepts, `LOCATION_WHEN_IN_USE` will be granted too. If the user denies, `LOCATION_WHEN_IN_USE` will be denied too.

### Testing with Jest

If you don't already have a Jest setup file configured, please add the following to your Jest configuration file and create the new `jest.setup.js` file in project root:

```js
setupFiles: ['<rootDir>/jest.setup.js'];
```

You can then add the following line to that setup file to mock the `NativeModule.RNPermissions`:

```js
jest.mock('react-native-permissions', () => require('react-native-permissions/mock'));
```

## Sponsors

This module is provided **as is**, I work on it in my free time.

If you or your company uses it in a production app, consider sponsoring this project 💰. You also can contact me for **premium** enterprise support: help with issues, prioritize bugfixes, feature requests, etc.

<a href="https://github.com/sponsors/zoontek"><img align="center" alt="Sponsors list" src="https://raw.githubusercontent.com/zoontek/sponsors/main/sponsorkit/sponsors.svg"></a>
