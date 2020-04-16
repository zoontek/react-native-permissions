import {
  NativeModules,
  Permission as CorePermission,
  PermissionsAndroid as Core,
  PermissionStatus as CoreStatus,
  Rationale,
} from 'react-native';
import {RESULTS} from './constants';
import {Contract} from './contract';
import {NotificationsResponse, Permission, PermissionStatus} from './types';
import {uniq} from './utils';

const RNP: {
  available: Permission[];

  checkNotifications: () => Promise<NotificationsResponse>;
  openSettings: () => Promise<true>;
  getNonRequestables: () => Promise<Permission[]>;
  isNonRequestable: (permission: Permission) => Promise<boolean>;
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

async function openSettings(): Promise<void> {
  await RNP.openSettings();
}

async function check(permission: Permission): Promise<PermissionStatus> {
  if (!RNP.available.includes(permission)) {
    return RESULTS.UNAVAILABLE;
  }

  if (await Core.check(permission as CorePermission)) {
    return RESULTS.GRANTED;
  }

  return (await RNP.isNonRequestable(permission))
    ? RESULTS.BLOCKED
    : RESULTS.DENIED;
}

async function request(
  permission: Permission,
  rationale?: Rationale,
): Promise<PermissionStatus> {
  if (!RNP.available.includes(permission)) {
    return RESULTS.UNAVAILABLE;
  }

  const status = coreStatusToStatus(
    await Core.request(permission as CorePermission, rationale),
  );

  if (status === RESULTS.BLOCKED) {
    await RNP.setNonRequestable(permission);
  }

  return status;
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

    if (RNP.available.includes(permission)) {
      available.push(permission);
    } else {
      unavailable[permission] = RESULTS.UNAVAILABLE;
    }
  }

  return {unavailable, available};
}

function checkNotifications(): Promise<NotificationsResponse> {
  return RNP.checkNotifications();
}

async function checkMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const dedup = uniq(permissions);
  const {unavailable: output, available} = splitByAvailability(dedup);
  const blocklist = await RNP.getNonRequestables();

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

async function requestMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const toSetAsNonRequestable: Permission[] = [];
  const dedup = uniq(permissions);
  const {unavailable: output, available} = splitByAvailability(dedup);
  const statuses = await Core.requestMultiple(available as CorePermission[]);

  for (const permission in statuses) {
    if (statuses.hasOwnProperty(permission)) {
      const status = coreStatusToStatus(statuses[permission as CorePermission]);
      output[permission as P[number]] = status;

      status === RESULTS.BLOCKED &&
        toSetAsNonRequestable.push(permission as Permission);
    }
  }

  if (toSetAsNonRequestable.length > 0) {
    await RNP.setNonRequestables(toSetAsNonRequestable);
  }

  return output as Record<P[number], PermissionStatus>;
}

export const module: Contract = {
  openSettings,
  check,
  request,
  checkNotifications,
  requestNotifications: checkNotifications,
  checkMultiple,
  requestMultiple,
};
