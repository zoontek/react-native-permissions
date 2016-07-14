# React Native Permissions
Request user permissions from React Native (iOS only - android coming soon)

The current supported permissions are:
- Push Notifications
- Location
- Camera
- Microhone
- Photos
- Contacts
- Events
- Reminders
- Bluetooth (Peripheral role. Don't use for Central only)
- Background Refresh

##General Usage
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

_Permission statuses_ - `authorized`, `denied`, `restricted`, or `undetermined`

_Permission types_ - `location`, `camera`, `microphone`, `photo`, `contacts`, `event`, `reminder`, `bluetooth`, `notification`, or `backgroundRefresh`

| Method Name | Arguments | Notes
|---|---|---|
| `getPermissionStatus` | `type` | - Returns a promise with the permission status. Note: for type `location`, iOS `AuthorizedAlways` and `AuthorizedWhenInUse` both return `authorized` |
| `requestPermission` | `type` | - Accepts any permission type except `backgroundRefresh`. If the current status is `undetermined`, shows the permission dialog and returns a promise with the resulting status. Otherwise, immediately return a promise with the current status. Note: see below for special cases|
| `checkMultiplePermissions` | `[types]` | - Accepts an array of permission types and returns a promise with an object mapping permission types to statuses |
| `getPermissionTypes` | *none* | - Returns an array of valid permission types  |
| `openSettings` | *none* | - Switches the user to the settings page of your app (iOS 8.0 and later)  |
| `canOpenSettings` | *none* | - Returns a boolean indicating if the device supports switching to the settings page |

Note: Permission type `bluetooth` represents the status of the `CBPeripheralManager`. Don't use this if you're only using `CBCentralManager`

###Special cases

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


##Setup

````
npm install --save react-native-permissions
````

##iOS
* Run open node_modules/react-native-permissions
* Drag ReactNativePermissions.xcodeproj into the Libraries group of your app's Xcode project
* Add libReactNativePermissions.a to `Build Phases -> Link Binary With Libraries.
