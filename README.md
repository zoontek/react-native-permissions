# React Native Permissions
Check user permissions (iOS only)

##What
Some iOS features require the user to grant permission before you can access them.

This library lets you check the current status of those permissions. (Note: it _doesn't_ prompt the user, just silently checks the permission status)

The current supported permissions are:
- Location
- Camera
- Microhone
- Photos
- Contacts
- Event
- Bluetooth (Peripheral role. Don't use for Central only)
- RemoteNotifications (Push Notifications)

####Example
```java
const Permissions = require('react-native-permissions');

//....
  componentDidMount() {
    Permissions.locationPermissionStatus()
    .then(response => {
      if (response == Permissions.StatusUndetermined) {
        console.log("Undetermined");
      } else if (response == Permissions.StatusDenied) {
        console.log("Denied");
      } else if (response == Permissions.StatusAuthorized) {
        console.log("Authorized");
      } else if (response == Permissions.StatusRestricted) {
        console.log("Restricted");
      }
    });
  }
//...
```


####API

As shown in the example, methods return a promise with the authorization status as an `int`. You can compare them to the following statuses: `StatusUndetermined`, `StatusDenied`, `StatusAuthorized`, `StatusRestricted`

`locationPermissionStatus()` - checks for access to the user's current location. Note: `AuthorizedAlways` and `AuthorizedWhenInUse` both return `StatusAuthorized`

`cameraPermissionStatus()` - checks for access to the phone's camera

`microphonePermissionStatus()` - checks for access to the phone's microphone

`photoPermissionStatus()` - checks for access to the user's photo album

`contactsPermissionStatus()` - checks for access to the user's address book

`eventPermissionStatus(eventType)` - requires param `eventType`; either `reminder` or `event`. Checks for access to the user's calendar events and reminders

`bluetoothPermissionStatus()` - checks the authorization status of the `CBPeripheralManager` (for sharing data while backgrounded). Note: _Don't_ use this if you're only using `CBCentralManager`

`notificationPermissionStatus()` - checks if the user has authorized remote push notifications. Note: iOS only tells us if the user has ever registered for notification, and which notifications are enabled. Therefore we cannot tell the difference between a user who has never been prompted for notification and a user who denied permission; both will return `StatusUndetermined`. You can determine if `StatusUndetermined` is actually `StatusDenied` by keeping track of whether or not you've already asked the user for permission. This promise *can* return `StatusDenied` if the user switched notifications off from the settings menu. Confusing, I know...

`backgroundRefreshStatus()` - checks the authorization status of background refresh


You also can open the Settings app.
`openSettings()` - open the Settings app. Note: this is only supported in ios >= 8. You can use `canOpenSettings()` to determine if it's supported.

##Setup

````
npm install --save react-native-permissions
````

###iOS
* Run open node_modules/react-native-permissions
* Drag ReactNativePermissions.xcodeproj into the Libraries group of your app's Xcode project
* Add libReactNativePermissions.a to `Build Phases -> Link Binary With Libraries.
