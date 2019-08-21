import {
  NativeModules,
  PermissionsAndroid,
  Platform,
  Rationale,
} from 'react-native';

const NativePermissionsAndroid = NativeModules.PermissionsAndroid;

const ANDROID = Object.freeze({
  ACCEPT_HANDOVER: 'android.permission.ACCEPT_HANDOVER' as const,
  ACCESS_BACKGROUND_LOCATION: 'android.permission.ACCESS_BACKGROUND_LOCATION' as const,
  ACCESS_COARSE_LOCATION: 'android.permission.ACCESS_COARSE_LOCATION' as const,
  ACCESS_FINE_LOCATION: 'android.permission.ACCESS_FINE_LOCATION' as const,
  ACTIVITY_RECOGNITION: 'android.permission.ACTIVITY_RECOGNITION' as const,
  ADD_VOICEMAIL: 'com.android.voicemail.permission.ADD_VOICEMAIL' as const,
  ANSWER_PHONE_CALLS: 'android.permission.ANSWER_PHONE_CALLS' as const,
  BODY_SENSORS: 'android.permission.BODY_SENSORS' as const,
  CALL_PHONE: 'android.permission.CALL_PHONE' as const,
  CAMERA: 'android.permission.CAMERA' as const,
  GET_ACCOUNTS: 'android.permission.GET_ACCOUNTS' as const,
  PROCESS_OUTGOING_CALLS: 'android.permission.PROCESS_OUTGOING_CALLS' as const,
  READ_CALENDAR: 'android.permission.READ_CALENDAR' as const,
  READ_CALL_LOG: 'android.permission.READ_CALL_LOG' as const,
  READ_CONTACTS: 'android.permission.READ_CONTACTS' as const,
  READ_EXTERNAL_STORAGE: 'android.permission.READ_EXTERNAL_STORAGE' as const,
  READ_PHONE_NUMBERS: 'android.permission.READ_PHONE_NUMBERS' as const,
  READ_PHONE_STATE: 'android.permission.READ_PHONE_STATE' as const,
  READ_SMS: 'android.permission.READ_SMS' as const,
  RECEIVE_MMS: 'android.permission.RECEIVE_MMS' as const,
  RECEIVE_SMS: 'android.permission.RECEIVE_SMS' as const,
  RECEIVE_WAP_PUSH: 'android.permission.RECEIVE_WAP_PUSH' as const,
  RECORD_AUDIO: 'android.permission.RECORD_AUDIO' as const,
  SEND_SMS: 'android.permission.SEND_SMS' as const,
  USE_SIP: 'android.permission.USE_SIP' as const,
  WRITE_CALENDAR: 'android.permission.WRITE_CALENDAR' as const,
  WRITE_CALL_LOG: 'android.permission.WRITE_CALL_LOG' as const,
  WRITE_CONTACTS: 'android.permission.WRITE_CONTACTS' as const,
  WRITE_EXTERNAL_STORAGE: 'android.permission.WRITE_EXTERNAL_STORAGE' as const,
});

const IOS = Object.freeze({
  BLUETOOTH_PERIPHERAL: 'ios.permission.BLUETOOTH_PERIPHERAL' as const,
  CALENDARS: 'ios.permission.CALENDARS' as const,
  CAMERA: 'ios.permission.CAMERA' as const,
  CONTACTS: 'ios.permission.CONTACTS' as const,
  FACE_ID: 'ios.permission.FACE_ID' as const,
  LOCATION_ALWAYS: 'ios.permission.LOCATION_ALWAYS' as const,
  LOCATION_WHEN_IN_USE: 'ios.permission.LOCATION_WHEN_IN_USE' as const,
  MEDIA_LIBRARY: 'ios.permission.MEDIA_LIBRARY' as const,
  MICROPHONE: 'ios.permission.MICROPHONE' as const,
  MOTION: 'ios.permission.MOTION' as const,
  PHOTO_LIBRARY: 'ios.permission.PHOTO_LIBRARY' as const,
  REMINDERS: 'ios.permission.REMINDERS' as const,
  SIRI: 'ios.permission.SIRI' as const,
  SPEECH_RECOGNITION: 'ios.permission.SPEECH_RECOGNITION' as const,
  STOREKIT: 'ios.permission.STOREKIT' as const,
});

export const PERMISSIONS = Object.freeze({ANDROID, IOS});

export const RESULTS = Object.freeze({
  UNAVAILABLE: 'unavailable' as const,
  DENIED: 'denied' as const,
  BLOCKED: 'blocked' as const,
  GRANTED: 'granted' as const,
});

type Values<T extends object> = T[keyof T];

export type AndroidPermission = Values<typeof ANDROID>;
export type IOSPermission = Values<typeof IOS>;
export type Permission = AndroidPermission | IOSPermission;

export type PermissionStatus = Values<typeof RESULTS>;

export type NotificationOption =
  | 'alert'
  | 'badge'
  | 'sound'
  | 'criticalAlert'
  | 'carPlay'
  | 'provisional';

export interface NotificationSettings {
  alert?: boolean;
  badge?: boolean;
  sound?: boolean;
  lockScreen?: boolean;
  carPlay?: boolean;
  critical?: boolean;
}

export interface NotificationsResponse {
  status: PermissionStatus;
  settings: NotificationSettings;
}

const RNPermissions: {
  openSettings: () => Promise<true>;
  check: (permission: Permission) => Promise<PermissionStatus>;
  request: (
    permission: Permission,
    rationale?: Rationale,
  ) => Promise<PermissionStatus>;
  checkNotifications: () => Promise<NotificationsResponse>;
  requestNotifications: (
    options: NotificationOption[],
  ) => Promise<NotificationsResponse>;

  // android only module methods
  isAvailable: (permission: Permission) => Promise<boolean>;
  setNonRequestable: (permission: Permission) => Promise<true>;
  getNonRequestables: () => Promise<Permission[]>;
} = NativeModules.RNPermissions;

const platformPermissions = Object.values(
  Platform.OS === 'ios' ? IOS : ANDROID,
);

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

  if (Platform.OS !== 'android') {
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

  if (!nonRequestables.includes(permission)) {
    return RESULTS.DENIED;
  }

  return (await NativePermissionsAndroid.shouldShowRequestPermissionRationale(
    permission,
  ))
    ? RESULTS.DENIED
    : RESULTS.BLOCKED;
}

export async function request(
  permission: Permission,
  rationale?: Rationale,
): Promise<PermissionStatus> {
  if (!isPlatformPermission(permission)) {
    return RESULTS.UNAVAILABLE;
  }

  if (Platform.OS !== 'android') {
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

export const checkNotifications = RNPermissions.checkNotifications;
export const requestNotifications = RNPermissions.requestNotifications;

export default {
  PERMISSIONS,
  RESULTS,
  openSettings,
  check,
  request,
  checkNotifications,
  requestNotifications,
};
