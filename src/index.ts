import {methods} from './methods';
import {PERMISSIONS} from './permissions';
import {RESULTS} from './results';

export {PERMISSIONS} from './permissions';
export {RESULTS} from './results';
export * from './types';

export const check = methods.check;
export const checkLocationAccuracy = methods.checkLocationAccuracy;
export const checkMultiple = methods.checkMultiple;
export const checkNotifications = methods.checkNotifications;
export const openPhotoPicker = methods.openPhotoPicker;
export const openSettings = methods.openSettings;
export const request = methods.request;
export const requestLocationAccuracy = methods.requestLocationAccuracy;
export const requestMultiple = methods.requestMultiple;
export const requestNotifications = methods.requestNotifications;

export default {
  PERMISSIONS,
  RESULTS,

  check,
  checkLocationAccuracy,
  checkMultiple,
  checkNotifications,
  openPhotoPicker,
  openSettings,
  request,
  requestLocationAccuracy,
  requestMultiple,
  requestNotifications,
};
