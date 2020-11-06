# Migration from v2

## What's new

- Windows support ([#530](https://github.com/zoontek/react-native-permissions/pull/530))
- Android 11 support
- iOS 9 support dropped
- New iOS permission handlers: `Permission-LocationAccuracy` ([#503](https://github.com/zoontek/react-native-permissions/pull/503)) and `Permission-PhotoLibraryAddOnly` ([#510](https://github.com/zoontek/react-native-permissions/pull/510))
- New methods for iOS14+: `checkLocationAccuracy`, `requestLocationAccuracy`, `openLimitedPhotoLibraryPicker` ([#503](https://github.com/zoontek/react-native-permissions/pull/503), [#510](https://github.com/zoontek/react-native-permissions/pull/510))
- Support of the new `Limited` status for `PhotoLibrary` permission ([#510](https://github.com/zoontek/react-native-permissions/pull/510))
- Support of the new `Limited` status for `Notifications` permission (=`Ephemeral`, (see [Apple doc](https://developer.apple.com/documentation/usernotifications/unauthorizationstatus/unauthorizationstatusephemeral?language=objc))

## Code modifications

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

## Known issues

Updating the permission status to `Ask me next time` in your app settings will not work on Android 11.
