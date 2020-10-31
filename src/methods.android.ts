import {
  NativeModules,
  Permission as CorePermission,
  PermissionsAndroid as Core,
  PermissionStatus as CoreStatus,
} from 'react-native';
import type {Contract} from './contract';
import {RESULTS} from './results';
import type {NotificationsResponse, Permission, PermissionStatus, Rationale} from './types';
import {
  checkLocationAccuracy,
  openLimitedPhotoLibraryPicker,
  requestLocationAccuracy,
} from './unsupportedPlatformMethods';
import {uniq} from './utils';

const NativeModule: {
  available: Permission[];

  checkNotifications: () => Promise<NotificationsResponse>;
  getNonRequestables: () => Promise<Permission[]>;
  isNonRequestable: (permission: Permission) => Promise<boolean>;
  openSettings: () => Promise<true>;
  setNonRequestable: (permission: Permission) => Promise<true>;
  setNonRequestables: (permissions: Permission[]) => Promise<true>;
} = NativeModules.RNPermissions;

function coreStatusToStatus(status: CoreStatus): PermissionStatus {
  switch (status) {
    case 'granted':
      return RESULTS.GRANTED;
    case 'denied':
      return RESULTS.DENIED;
    case 'never_ask_again':
      return RESULTS.BLOCKED;
    default:
      return RESULTS.UNAVAILABLE;
  }
}

function splitByAvailability<P extends Permission[]>(
  permissions: P,
): {
  unavailable: Partial<Record<P[number], PermissionStatus>>;
  available: P[number][];
} {
  const unavailable: Partial<Record<P[number], PermissionStatus>> = {};
  const available: P[number][] = [];

  for (let index = 0; index < permissions.length; index++) {
    const permission: P[number] = permissions[index];

    if (NativeModule.available.includes(permission)) {
      available.push(permission);
    } else {
      unavailable[permission] = RESULTS.UNAVAILABLE;
    }
  }

  return {unavailable, available};
}

async function check(permission: Permission): Promise<PermissionStatus> {
  if (!NativeModule.available.includes(permission)) {
    return RESULTS.UNAVAILABLE;
  }

  if (await Core.check(permission as CorePermission)) {
    return RESULTS.GRANTED;
  }

  return (await NativeModule.isNonRequestable(permission)) ? RESULTS.BLOCKED : RESULTS.DENIED;
}

async function checkMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const dedup = uniq(permissions);
  const {unavailable: output, available} = splitByAvailability(dedup);
  const blocklist = await NativeModule.getNonRequestables();

  await Promise.all(
    available.map(async (permission: P[number]) => {
      const granted = await Core.check(permission as CorePermission);

      output[permission] = granted
        ? RESULTS.GRANTED
        : blocklist.includes(permission)
        ? RESULTS.BLOCKED
        : RESULTS.DENIED;
    }),
  );

  return output as Record<P[number], PermissionStatus>;
}

function checkNotifications(): Promise<NotificationsResponse> {
  return NativeModule.checkNotifications();
}

async function openSettings(): Promise<void> {
  await NativeModule.openSettings();
}

async function request(permission: Permission, rationale?: Rationale): Promise<PermissionStatus> {
  if (!NativeModule.available.includes(permission)) {
    return RESULTS.UNAVAILABLE;
  }

  const status = coreStatusToStatus(await Core.request(permission as CorePermission, rationale));

  if (status === RESULTS.BLOCKED) {
    await NativeModule.setNonRequestable(permission);
  }

  return status;
}

async function requestMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const toSetAsNonRequestable: Permission[] = [];
  const dedup = uniq(permissions);
  const {unavailable: output, available} = splitByAvailability(dedup);
  const statuses = await Core.requestMultiple(available as CorePermission[]);

  for (const permission in statuses) {
    if (Object.prototype.hasOwnProperty.call(statuses, permission)) {
      const status = coreStatusToStatus(statuses[permission as CorePermission]);
      output[permission as P[number]] = status;

      if (status === RESULTS.BLOCKED) {
        toSetAsNonRequestable.push(permission as Permission);
      }
    }
  }

  if (toSetAsNonRequestable.length > 0) {
    await NativeModule.setNonRequestables(toSetAsNonRequestable);
  }

  return output as Record<P[number], PermissionStatus>;
}

export const methods: Contract = {
  check,
  checkLocationAccuracy,
  checkMultiple,
  checkNotifications,
  openLimitedPhotoLibraryPicker,
  openSettings,
  request,
  requestLocationAccuracy,
  requestMultiple,
  requestNotifications: checkNotifications,
};
