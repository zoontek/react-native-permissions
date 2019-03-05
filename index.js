// @flow

import {
  AsyncStorage,
  NativeModules,
  PermissionsAndroid,
  Platform,
  // $FlowFixMe
} from "react-native";

const { RNPermissions } = NativeModules;

export const ANDROID_PERMISSIONS = {
  ...PermissionsAndroid.PERMISSIONS,
  // Dangerous permissions not included in PermissionsAndroid
  // They might be unavailable in the current OS
  ANSWER_PHONE_CALLS: "android.permission.ANSWER_PHONE_CALLS",
  ACCEPT_HANDOVER: "android.permission.ACCEPT_HANDOVER",
  READ_PHONE_NUMBERS: "android.permission.READ_PHONE_NUMBERS",
};

// function keyMirror<O: {}>(obj: O): $ObjMapi<O, <K>(k: K) => K> {
//   return Object.keys(obj).reduce((acc, key) => ({ ...acc, [key]: key }), {});
// }

export const IOS_PERMISSIONS = {
  BLUETOOTH_PERIPHERAL: "BLUETOOTH_PERIPHERAL",
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

export type RequestConfig = {
  notificationOptions?: NotificationOption[],
  rationale?: Rationale,
};

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
  ).then(availabilities =>
    availabilities.reduce((acc, available, i) => {
      return !available
        ? { ...acc, [permissions[i]]: RESULTS.UNAVAILABLE }
        : acc;
    }, {}),
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
  return AsyncStorage.setItem(requestedKey, JSON.stringify(dedup));
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
  config: RequestConfig = {},
): Promise<PermissionStatus> {
  const { notificationOptions, rationale } = config;

  if (Platform.OS !== "android") {
    return RNPermissions.request(permission, { notificationOptions });
  }

  if (!(await RNPermissions.isPermissionAvailable(permission))) {
    return RESULTS.UNAVAILABLE;
  }

  const status = await PermissionsAndroid.request(permission, rationale);
  return setRequestedPermissions([permission]).then(() => status);
}

async function internalCheckMultiple(
  permissions: Permission[],
): Promise<{ [permission: Permission]: PermissionStatus }> {
  let available = permissions;
  let result = {};

  if (Platform.OS === "android") {
    result = await getUnavailablePermissions(permissions);
    const unavailable = Object.keys(result);
    available = permissions.filter(p => !unavailable.includes(p));
  }

  return Promise.all(available.map(p => internalCheck(p)))
    .then(statuses =>
      statuses.reduce((acc, status, i) => {
        return { ...acc, [available[i]]: status };
      }, {}),
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
      result[permission] = await internalRequest(permission); // once at the time
    }

    return result;
  }

  const result = await getUnavailablePermissions(permissions);
  const unavailable = Object.keys(result);

  const statuses = await PermissionsAndroid.requestMultiple(
    permissions.filter(p => !unavailable.includes(p)),
  ).then(statuses => ({ ...result, ...statuses }));

  return setRequestedPermissions(permissions).then(() => statuses);
}

export function openSettings(): Promise<boolean> {
  return RNPermissions.openSettings();
}

export function check(permission: Permission): Promise<PermissionStatus> {
  assertValidPermission(permission);
  return internalCheck(permission);
}

export function checkMultiple<P: Permission>(
  permissions: P[],
): Promise<{ [permission: P]: PermissionStatus }> {
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

export function requestMultiple<P: Permission>(
  permissions: P[],
): Promise<{ [permission: P]: PermissionStatus }> {
  permissions.forEach(assertValidPermission);
  return internalRequestMultiple(permissions);
}
