// @flow

import {
  AsyncStorage,
  NativeModules,
  PermissionsAndroid,
  Platform,
} from "react-native";

const { RNPermissions } = NativeModules;

export const ANDROID_PERMISSIONS = {
  ...PermissionsAndroid.PERMISSIONS,
  // Dangerous permissions not included in PermissionsAndroid (which might be unavailable)
  ACCEPT_HANDOVER: "android.permission.ACCEPT_HANDOVER",
  // @TODO Add more of them (https://developer.android.com/reference/android/Manifest.permission)
};

// function keyMirror<O: {}>(obj: O): $ObjMapi<O, <K>(k: K) => K> {
//   return Object.keys(obj).reduce((acc, key) => ({ ...acc, [key]: key }), {});
// }

export const IOS_PERMISSIONS = {
  BLUETOOTH_PERIPHERICAL: "BLUETOOTH_PERIPHERICAL",
  CALENDARS: "CALENDARS",
  CAMERA: "CAMERA",
  CONTACTS: "CONTACTS",
  FACE_ID: "FACE_ID",
  LOCATION_ALWAYS: "LOCATION_ALWAYS",
  LOCATION_WHEN_IN_USE: "LOCATION_WHEN_IN_USE",
  MEDIA_LIBRARY: "MEDIA_LIBRARY",
  MICROPHONE: "MICROPHONE",
  MOTION: "MOTION",
  NOTIFICATIONS: "NOTIFICATIONS",
  PHOTO_LIBRARY: "PHOTO_LIBRARY",
  REMINDERS: "REMINDERS",
  SIRI: "SIRI",
  SPEECH_RECOGNITION: "SPEECH_RECOGNITION",
  STOREKIT: "STOREKIT",
};

export const RESULTS = {
  GRANTED: "granted",
  DENIED: "denied",
  NEVER_ASK_AGAIN: "never_ask_again",
  UNAVAILABLE: "unavailable",
};

export type Permission =
  | $Keys<typeof ANDROID_PERMISSIONS>
  | $Keys<typeof IOS_PERMISSIONS>;

export type PermissionStatus = $Values<typeof RESULTS>;

export type Rationale = {|
  title: string,
  message: string,
  buttonPositive: string,
  buttonNegative?: string,
  buttonNeutral?: string,
|};

export type NotificationOption =
  | "badge"
  | "sound"
  | "alert"
  | "carPlay"
  | "criticalAlert"
  | "provisional";

export type RequestConfig = {|
  notificationOptions?: NotificationOption[],
  rationale?: Rationale,
|};

const platformPermissions = Object.values(
  Platform.OS === "ios" ? IOS_PERMISSIONS : ANDROID_PERMISSIONS,
);

function assertValidPermission(permission: string) {
  if (!platformPermissions.includes(permission)) {
    const bulletsList = `• ${platformPermissions.join("\n• ")}`;
    const alertSentence = `Invalid ${
      Platform.OS
    } permission "${permission}". Must be one of:\n\n`;

    throw new Error(`${alertSentence}${bulletsList}`);
  }
}

function getUnavailablePermissions(permissions: string[]) {
  return Promise.all(
    permissions.map(p => RNPermissions.isPermissionAvailable(p)),
  ).then(result =>
    result.reduce(
      (acc, isAvailable, i) =>
        isAvailable ? acc : { ...acc, [permissions[i]]: RESULTS.UNAVAILABLE },
      {},
    ),
  );
}

const requestedKey = "@RNPermissions:requested";

async function getRequestedPermissions() {
  const requested = await AsyncStorage.getItem(requestedKey);

  return requested ? JSON.parse(requested) : [];
}

async function setRequestedPermissions(permissions: string[]) {
  const requested = await getRequestedPermissions();
  const dedup = [...new Set([...requested, ...permissions])];

  return AsyncStorage.setItem(requestedKey, dedup);
}

async function internalCheck(
  permission: Permission,
): Promise<PermissionStatus> {
  if (Platform.OS !== "android") {
    return RNPermissions.check(permission);
  }

  if (!(await RNPermissions.isPermissionAvailable(permission))) {
    return RESULTS.UNAVAILABLE;
  }
  if (await PermissionsAndroid.check(permission)) {
    return RESULTS.GRANTED;
  }
  if (!(await getRequestedPermissions()).includes(permission)) {
    return RESULTS.DENIED;
  }

  return (await NativeModules.PermissionsAndroid.shouldShowRequestPermissionRationale(
    permission,
  ))
    ? RESULTS.DENIED
    : RESULTS.NEVER_ASK_AGAIN;
}

async function internalRequest(
  permission: string,
  config: RequestConfig,
): Promise<PermissionStatus> {
  const { notificationOptions, rationale } = config;

  if (Platform.OS !== "android") {
    return RNPermissions.request(permission, { notificationOptions });
  }
  if (!(await RNPermissions.isPermissionAvailable(permission))) {
    return RESULTS.UNAVAILABLE;
  }

  const status = await PermissionsAndroid.request(permission, rationale);

  // set permission as requested
  await setRequestedPermissions([permission]);
  return status;
}

async function internalCheckMultiple(
  permissions: Permission[],
): Promise<{ [permission: Permission]: PermissionStatus }> {
  const result = await getUnavailablePermissions(permissions);
  const unavailable = Object.keys(result);
  const available = permissions.filter(p => !unavailable.includes(p));

  return Promise.all(available.map(p => internalCheck(p)))
    .then(statuses =>
      statuses.reduce((acc, s, i) => ({ ...acc, [available[i]]: s }), {}),
    )
    .then(statuses => ({ ...result, ...statuses }));
}

async function internalRequestMultiple(
  permissions: Permission[],
): Promise<{ [permission: Permission]: PermissionStatus }> {
  if (Platform.OS !== "android") {
    const result = {};

    for (let i = 0; i < permissions.length; i++) {
      const permission = permissions[i];
      // avoid checking them all at once
      result[permission] = await internalRequest(permission);
    }

    return result;
  }

  const result = await getUnavailablePermissions(permissions);
  const unavailable = Object.keys(result);

  const statuses = await PermissionsAndroid.requestMultiple(
    permissions.filter(p => !unavailable.includes(p)),
  ).then(statuses => ({ ...result, ...statuses }));

  // set permissions as requested
  await setRequestedPermissions(permissions);
  return status;
}

export function openSettings(): Promise<boolean> {
  return RNPermissions.openSettings();
}

export function check(permission: Permission): Promise<PermissionStatus> {
  assertValidPermission(permission);
  return internalCheck(permission);
}

export function checkMultiple(
  permissions: Permission[],
): Promise<{ [permission: Permission]: PermissionStatus }> {
  permissions.forEach(assertValidPermission);
  return internalCheckMultiple(permissions);
}

export function request(
  permission: string,
  config: RequestConfig = {},
): Promise<PermissionStatus> {
  assertValidPermission(permission);
  return internalRequest(permission, config);
}

export function requestMultiple(
  permissions: Permission[],
): Promise<{ [permission: Permission]: PermissionStatus }> {
  permissions.forEach(assertValidPermission);
  return internalRequestMultiple(permissions);
}
