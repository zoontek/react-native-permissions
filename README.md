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


###New in version 0.2.X
- Android support 🎉🎉🍾
- Example app

##General Usage
```
npm install --save react-native-permissions
rnpm link
```

```js
const Permissions = require('react-native-permissions');

//...
  //check the status of a single permission
  componentDidMount() {
    Permissions.getPermissionStatus('photo')
      .then(response => {
        //response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
        this.setState({ photoPermission: response })
      });
  }

  //request permission to access photos
  _requestPermission() {
    Permissions.requestPermission('photo')
      .then(response => {
        //returns once the user has chosen to 'allow' or to 'not allow' access
        //response is one of: 'authorized', 'denied', 'restricted', or 'undetermined'
        this.setState({ photoPermission: response })
      });
  }

  //check the status of multiple permissions
  _checkCameraAndPhotos() {
    Permissions.checkMultiplePermissions(['camera', 'photo'])
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

##API

###Permission statuses
Promises resolve into one of these statuses

| Return value | Notes|
|---|---|
|`authorized`| user has authorized this permission |
|`denied`| user has denied this permission at least once. On iOS this means that the user will not be prompted again. Android users can be promted multiple times until they select 'Never ask me again'|
|`restricted`| *(iOS only)* user is not able to grant this permission, either because it's not supported by the device or because it has been blocked by parental controls. |
|`undetermined`| user has not yet been prompted with a permission dialog |

###Supported permission types

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

###Methods
| Method Name | Arguments | Notes
|---|---|---|
| `getPermissionStatus` | `type` | - Returns a promise with the permission status. Note: for type `location`, iOS `AuthorizedAlways` and `AuthorizedWhenInUse` both return `authorized` |
| `requestPermission` | `type` | - Accepts any permission type except `backgroundRefresh`. If the current status is `undetermined`, shows the permission dialog and returns a promise with the resulting status. Otherwise, immediately return a promise with the current status. See iOS Notes for special cases|
| `checkMultiplePermissions` | `[types]` | - Accepts an array of permission types and returns a promise with an object mapping permission types to statuses |
| `getPermissionTypes` | *none* | - Returns an array of valid permission types  |
| `openSettings` | *none* | - Switches the user to the settings page of your app (iOS 8.0 and later)  |
| `canOpenSettings` | *none* | - Returns a boolean indicating if the device supports switching to the settings page |

###iOS Notes
Permission type `bluetooth` represents the status of the `CBPeripheralManager`. Don't use this if only need `CBCentralManager`

`requestPermission` also accepts a second parameter for types `location` and `notification`.
- `location`: the second parameter is a string, either `always` or `whenInUse`(default).
- `notification`: the second parameter is an array with the desired alert types. Any combination of `alert`, `badge` and `sound` (default requests all three)
```js
///example
    Permissions.requestPermission('location', 'always')
      .then(response => {
        this.setState({ locationPermission: response })
      })

    Permissions.requestPermission('notification', ['alert', 'badge'])
      .then(response => {
        this.setState({ notificationPermission: response })
      })
```

###Android Notes

Requires RN >= 0.29.0

All required permissions also need to be included in the Manifest before they can be requested. Otherwise `requestPermission` will immediately return `denied`.

Permissions are automatically accepted for targetSdkVersion < 23 but you can still use `getPermissionStatus` to check if the user has disabled them from Settings.

Here's a map of types to Android system permissions names:  
`location` -> `android.permission.ACCESS_FINE_LOCATION`  
`camera` -> `android.permission.CAMERA`  
`microphone` -> `android.permission.RECORD_AUDIO`  
`photo` -> `android.permission.READ_EXTERNAL_STORAGE`  
`contacts` -> `android.permission.READ_CONTACTS`  
`event` -> `android.permission.READ_CALENDAR`  

You can request write access to any of these types by also including the appropriate write permission in the Manifest. Read more here: https://developer.android.com/guide/topics/security/permissions.html#normal-dangerous

##Setup

````
npm install --save react-native-permissions
rnpm link
````

###Or manualy linking   

####iOS
* Run open node_modules/react-native-permissions
* Drag ReactNativePermissions.xcodeproj into the Libraries group of your app's Xcode project
* Add libReactNativePermissions.a to `Build Phases -> Link Binary With Libraries.

####Android
#####Step 1 - Update Gradle Settings

```
// file: android/settings.gradle
...

include ':react-native-permissions'
project(':react-native-permissions').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-permissions/android')
```
#####Step 2 - Update Gradle Build

```
// file: android/app/build.gradle
...

dependencies {
    ...
    compile project(':react-native-permissions')
}
```
#####Step 3 - Register React Package
```
...
import com.joshblour.reactnativepermissions.ReactNativePermissionsPackage; // <--- import

public class MainApplication extends Application implements ReactApplication {

    ...

    @Override
    protected List<ReactPackage> getPackages() {
        return Arrays.<ReactPackage>asList(
            new MainReactPackage(),
            new ReactNativePermissionsPackage() // <------ add the package
        );
    }

    ...
}
```

##Troubleshooting

#### Q: Android - `undefined is not a object (evaluating 'RNPermissions.requestPermissions')`
A: `rnpm` may not have linked correctly. Follow the manual linking steps and make sure the library is linked 
