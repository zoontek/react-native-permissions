import {NativeModules} from 'react-native';
import {PERMISSIONS, RESULTS} from './constants';
import {module} from './module';

if (NativeModules.RNPermissions == null) {
  throw new Error(`react-native-permissions: NativeModule.RNPermissions is null. To fix this issue try these steps:
  • If you are using CocoaPods on iOS, run \`pod install\` in the \`ios\` directory and then clean, rebuild and re-run the app. You may also need to re-open Xcode to get the new pods.
  • If you are getting this error while unit testing you need to mock the native module. You can use this to get started: https://github.com/react-native-community/react-native-permissions/blob/master/mock.js
  If none of these fix the issue, please open an issue on the Github repository: https://github.com/react-native-community/react-native-permissions`);
}

export {PERMISSIONS, RESULTS} from './constants';
export * from './types';

export const openSettings = module.openSettings;
export const check = module.check;
export const request = module.request;
export const checkNotifications = module.checkNotifications;
export const requestNotifications = module.requestNotifications;
export const checkMultiple = module.checkMultiple;
export const requestMultiple = module.requestMultiple;

export default {
  PERMISSIONS,
  RESULTS,
  openSettings,
  check,
  request,
  checkNotifications,
  requestNotifications,
  checkMultiple,
  requestMultiple,
};
