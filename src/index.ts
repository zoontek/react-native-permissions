import {NativeModules} from 'react-native';
import {module} from './module';
import {PERMISSIONS} from './permissions';
import {RESULTS} from './results';

if (NativeModules.RNPermissions == null) {
  throw new Error(`react-native-permissions: NativeModule.RNPermissions is null. To fix this issue try these steps:
• If you are using CocoaPods on iOS, run \`pod install\` in the \`ios\` directory and then clean, rebuild and re-run the app. You may also need to re-open Xcode to get the new pods.
• If you are getting this error while unit testing you need to mock the native module. You can use this to get started: https://github.com/zoontek/react-native-permissions/blob/master/mock.js
If none of these fix the issue, please open an issue on the Github repository: https://github.com/zoontek/react-native-permissions`);
}

export {PERMISSIONS} from './permissions';
export {RESULTS} from './results';
export * from './types';

export const check = module.check;
export const checkLocationAccuracy = module.checkLocationAccuracy;
export const checkMultiple = module.checkMultiple;
export const checkNotifications = module.checkNotifications;
export const openLimitedPhotoLibraryPicker = module.openLimitedPhotoLibraryPicker;
export const openSettings = module.openSettings;
export const request = module.request;
export const requestLocationAccuracy = module.requestLocationAccuracy;
export const requestMultiple = module.requestMultiple;
export const requestNotifications = module.requestNotifications;

export default {
  PERMISSIONS,
  RESULTS,

  check,
  checkLocationAccuracy,
  checkMultiple,
  checkNotifications,
  openLimitedPhotoLibraryPicker,
  openSettings,
  request,
  requestLocationAccuracy,
  requestMultiple,
  requestNotifications,
};
