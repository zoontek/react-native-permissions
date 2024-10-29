const {
  PERMISSIONS: {ANDROID},
} = require('./dist/commonjs/permissions.android');
const {
  PERMISSIONS: {IOS},
} = require('./dist/commonjs/permissions.ios');
const {
  PERMISSIONS: {WINDOWS},
} = require('./dist/commonjs/permissions.windows');
const {RESULTS} = require('./dist/commonjs/results');

const PERMISSIONS = {ANDROID, IOS, WINDOWS};
export {PERMISSIONS, RESULTS};

export const canScheduleExactAlarms = jest.fn(async () => true);
export const check = jest.fn(async () => RESULTS.GRANTED);
export const checkLocationAccuracy = jest.fn(async () => 'full');
export const openPhotoPicker = jest.fn(async () => {});
export const openSettings = jest.fn(async () => {});
export const request = jest.fn(async () => RESULTS.GRANTED);
export const requestLocationAccuracy = jest.fn(async () => 'full');

const notificationOptions = [
  'alert',
  'badge',
  'sound',
  'carPlay',
  'criticalAlert',
  'provisional',
  'providesAppSettings',
];

const notificationSettings = {
  alert: true,
  badge: true,
  sound: true,
  carPlay: true,
  criticalAlert: true,
  provisional: true,
  providesAppSettings: true,
  lockScreen: true,
  notificationCenter: true,
};

export const checkNotifications = jest.fn(async () => ({
  status: RESULTS.GRANTED,
  settings: notificationSettings,
}));

export const requestNotifications = jest.fn(async (options) => ({
  status: RESULTS.GRANTED,
  settings: options
    .filter((option) => notificationOptions.includes(option))
    .reduce((acc, option) => ({...acc, [option]: true}), {
      lockScreen: true,
      notificationCenter: true,
    }),
}));

export const checkMultiple = jest.fn(async (permissions) =>
  permissions.reduce((acc, permission) => ({...acc, [permission]: RESULTS.GRANTED}), {}),
);

export const requestMultiple = jest.fn(async (permissions) =>
  permissions.reduce((acc, permission) => ({...acc, [permission]: RESULTS.GRANTED}), {}),
);

export default {
  PERMISSIONS,
  RESULTS,

  canScheduleExactAlarms,
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
