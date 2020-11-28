# Migration from v2

## What's new

- Windows support ([#530](https://github.com/zoontek/react-native-permissions/pull/530) by @bzoz)
- Android 11 support
- iOS 14 support added, iOS 9 support dropped
- Updated example app
- New iOS 14+ permission handler: `Permission-PhotoLibraryAddOnly`. It exposes a new method: `openLimitedPhotoLibraryPicker` ([#510](https://github.com/zoontek/react-native-permissions/pull/510) by @jochem725)
- New iOS 14+ permission handler: `Permission-LocationAccuracy`. It exposes two new methods: `checkLocationAccuracy` & `requestLocationAccuracy` ([#503](https://github.com/zoontek/react-native-permissions/pull/503) by @adapptor-kurt)
- Support of the new `Limited` status for `PhotoLibrary` permission ([#510](https://github.com/zoontek/react-native-permissions/pull/510) by @jochem725)
- Support of the new `Limited` status for `Notifications` permission (=`Ephemeral`, (see [Apple doc](https://developer.apple.com/documentation/usernotifications/unauthorizationstatus/unauthorizationstatusephemeral?language=objc))

## Breaking changes

1. `.podspec` extension is no longer required in your `Podfile`:

```diff
target 'YourAwesomeProject' do

  # …

  permissions_path = '../node_modules/react-native-permissions/ios'

- pod 'Permission-Calendars', :path => "#{permissions_path}/Calendars.podspec"
+ pod 'Permission-Calendars', :path => "#{permissions_path}/Calendars"
- pod 'Permission-Camera', :path => "#{permissions_path}/Camera.podspec"
+ pod 'Permission-Camera', :path => "#{permissions_path}/Camera"

  # …

end
```

2. `request(PERMISSIONS.IOS.PHOTO_LIBRARY)` and `requestNotifications` could now resolve with a `RESULTS.LIMITED` permission status.

## Known issue

Updating the permission status to `Ask me next time` in your app settings will not update the permission status on Android 11 for now.
