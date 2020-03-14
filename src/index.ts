import {
  NativeModules,
  PermissionsAndroid,
  Platform,
  Rationale,
} from 'react-native';

import {
  NotificationOption,
  NotificationsResponse,
  Permission,
  PermissionStatus,
} from './types';

import {ANDROID, IOS, PERMISSIONS, RESULTS} from './constants';

const RNPermissions: {
  // Android + iOS
  checkNotifications: () => Promise<NotificationsResponse>;
  requestNotifications: (
    options: NotificationOption[],
  ) => Promise<NotificationsResponse>;
  openSettings: () => Promise<true>;

  // Android only
  isAvailable: (permission: Permission) => Promise<boolean>;
  getNonRequestables: () => Promise<Permission[]>;
  setNonRequestable: (permission: Permission) => Promise<true>;

  // iOS only
  check: (permission: Permission) => Promise<PermissionStatus>;
  request: (
    permission: Permission,
    rationale?: Rationale,
  ) => Promise<PermissionStatus>;
} = NativeModules.RNPermissions;

// Produce an error if we don't have the native module
if (RNPermissions == null) {
  throw new Error(`react-native-permissions: NativeModule.RNPermissions is null. To fix this issue try these steps:
• If you are using CocoaPods on iOS, run \`pod install\` in the \`ios\` directory and then rebuild and re-run the app. You may also need to re-open Xcode to get the new pods.
* If you are getting this error while unit testing you need to mock the native module. Follow the guide in the README.
If none of these fix the issue, please open an issue on the Github repository: https://github.com/react-native-community/react-native-permissions`);
}

const platformPermissions = Platform.select<Permission[]>({
  ios: Object.values(IOS),
  android: Object.values(ANDROID),
  default: [],
});

function isPlatformPermission(permission: Permission): boolean {
  if (platformPermissions.includes(permission)) {
    return true;
  }

  if (__DEV__) {
    let message = '';
    message += `Invalid ${Platform.OS} permission "${permission}".`;
    message += ' Must be one of:\n\n• ';
    message += platformPermissions.join('\n• ');
    console.error(message);
  }

  return false;
}

export function openSettings(): Promise<void> {
  return RNPermissions.openSettings().then(() => {});
}

export async function check(permission: Permission): Promise<PermissionStatus> {
  if (!isPlatformPermission(permission)) {
    return RESULTS.UNAVAILABLE;
  }

  if (Platform.OS === 'ios') {
    return RNPermissions.check(permission);
  }

  const available = await RNPermissions.isAvailable(permission);

  if (!available) {
    return RESULTS.UNAVAILABLE;
  }

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  if (await PermissionsAndroid.check(permission as any)) {
    return RESULTS.GRANTED;
  }

  const nonRequestables = await RNPermissions.getNonRequestables();

  return nonRequestables.includes(permission)
    ? RESULTS.BLOCKED
    : RESULTS.DENIED;
}

export async function request(
  permission: Permission,
  rationale?: Rationale,
): Promise<PermissionStatus> {
  if (!isPlatformPermission(permission)) {
    return RESULTS.UNAVAILABLE;
  }

  if (Platform.OS === 'ios') {
    return RNPermissions.request(permission);
  }

  const available = await RNPermissions.isAvailable(permission);

  if (!available) {
    return RESULTS.UNAVAILABLE;
  }

  const status = await PermissionsAndroid.request(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    permission as any,
    rationale,
  );

  if (status === 'granted') {
    return RESULTS.GRANTED;
  }

  if (status === 'denied') {
    return RESULTS.DENIED;
  }

  if (status === 'never_ask_again') {
    await RNPermissions.setNonRequestable(permission);
    return RESULTS.BLOCKED;
  }

  return RESULTS.UNAVAILABLE;
}

export function checkNotifications(): Promise<NotificationsResponse> {
  return RNPermissions.checkNotifications();
}

export function requestNotifications(
  options: NotificationOption[],
): Promise<NotificationsResponse> {
  return RNPermissions.requestNotifications(options);
}

export * from './types';
export {PERMISSIONS, RESULTS} from './constants';

export default {
  PERMISSIONS,
  RESULTS,
  openSettings,
  check,
  request,
  checkNotifications,
  requestNotifications,
};
