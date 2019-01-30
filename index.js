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

const requestedKey = "@RNPermissions:requested";

const platformPermissions = Object.values(
  Platform.OS === "android" ? ANDROID_PERMISSIONS : IOS_PERMISSIONS,
);

function assertValidPermission(permission: string) {
  if (platformPermissions.includes(permission)) {
    return;
  }

  const bulletsList = `• ${platformPermissions.join("\n• ")}`;
  const alertSentence = `Invalid ${
    Platform.OS
  } permission "${permission}". Must be one of:\n\n`;

  throw new Error(`${alertSentence}${bulletsList}`);
}

async function getRequestedPermissions() {
  const requested = await AsyncStorage.getItem(requestedKey);
  return requested ? JSON.parse(requested) : [];
}

async function setRequestedPermission(permission: string) {
  const requested = await getRequestedPermissions();

  if (requested.includes(permission)) {
    return;
  }

  return await AsyncStorage.setItem(
    requestedKey,
    JSON.stringify([...requested, permission]),
  );
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

  const result = await PermissionsAndroid.request(permission, rationale);
  await setRequestedPermission(permission);

  return result;
}

export function openSettings(): Promise<boolean> {
  return RNPermissions.openSettings();
}

export function check(permission: Permission): Promise<PermissionStatus> {
  assertValidPermission(permission);
  return internalCheck(permission);
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
  permissions.forEach(permission => {
    assertValidPermission(permission);
  });

  return (async () => {
    const result = {};

    if (Platform.OS !== "android") {
      for (let index = 0; index < permissions.length; index++) {
        const permission = permissions[index];
        result[permission] = await request(permission);
      }

      return result;
    }

    const available = [];

    for (let index = 0; index < permissions.length; index++) {
      const permission = permissions[index];

      // @TODO Do checks in parallel to improve performances
      if (await RNPermissions.isPermissionAvailable(permission)) {
        available.push(permission);
      } else {
        result[permission] = RESULTS.UNAVAILABLE;
      }
    }

    return PermissionsAndroid.requestMultiple(available).then(statuses => ({
      ...result,
      ...statuses,
    }));
  })();
}
