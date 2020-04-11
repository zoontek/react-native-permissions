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

function grantedToStatus(granted: boolean): PermissionStatus {
  return granted ? RESULTS.GRANTED : RESULTS.DENIED;
}

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
  if (await RNP.isNonRequestable(permission)) {
    return RESULTS.BLOCKED;
  }

  const granted = await Core.check(permission as CorePermission);
  return grantedToStatus(granted);
}

async function request(
  permission: Permission,
  rationale?: Rationale,
): Promise<PermissionStatus> {
  if (!RNP.available.includes(permission)) {
    return RESULTS.UNAVAILABLE;
  }
  if (await RNP.isNonRequestable(permission)) {
    return RESULTS.BLOCKED;
  }

  const status = coreStatusToStatus(
    await Core.request(permission as CorePermission, rationale),
  );

  if (status === RESULTS.BLOCKED) {
    await RNP.setNonRequestable(permission);
  }

  return status;
}

async function splitByUsability<P extends Permission[]>(
  permissions: P,
): Promise<{
  unusables: Partial<Record<P[number], PermissionStatus>>;
  usables: P[number][];
}> {
  const unusables: Partial<Record<P[number], PermissionStatus>> = {};
  const usables: P[number][] = [];
  const blocklist = await RNP.getNonRequestables();

  for (let index = 0; index < permissions.length; index++) {
    const permission: P[number] = permissions[index];

    if (blocklist.includes(permission)) {
      unusables[permission] = RESULTS.BLOCKED;
      continue;
    }
    if (!RNP.available.includes(permission)) {
      unusables[permission] = RESULTS.UNAVAILABLE;
      continue;
    }

    usables.push(permission);
  }

  return {unusables, usables};
}

function checkNotifications(): Promise<NotificationsResponse> {
  return RNP.checkNotifications();
}

async function checkMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const dedup = uniq(permissions);
  const {unusables: output, usables} = await splitByUsability(dedup);

  await Promise.all(
    usables.map(async (permission: P[number]) => {
      const granted = await Core.check(permission as CorePermission);
      output[permission] = grantedToStatus(granted);
    }),
  );

  return output as Record<P[number], PermissionStatus>;
}

async function requestMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const toSetAsNonRequestable: Permission[] = [];
  const dedup = uniq(permissions);
  const {unusables: output, usables} = await splitByUsability(dedup);
  const statuses = await Core.requestMultiple(usables as CorePermission[]);

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
