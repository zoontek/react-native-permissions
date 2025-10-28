import type {Contract} from './contract';
import NativeModule from './specs/NativeRNPermissions';
import type {NotificationsResponse, PermissionStatus} from './types';
import {
  canScheduleExactAlarms,
  canUseFullScreenIntent,
  checkLocationAccuracy,
  openPhotoPicker,
  requestLocationAccuracy,
} from './unsupportedMethods';
import {uniq} from './utils';

const openSettings: Contract['openSettings'] = async () => {
  await NativeModule.openSettings('N/A');
};

const check: Contract['check'] = async (permission) => {
  const response = (await NativeModule.check(permission)) as PermissionStatus;
  return response;
};

const request: Contract['request'] = async (permission) => {
  const response = (await NativeModule.request(permission)) as PermissionStatus;
  return response;
};

const checkNotifications: Contract['checkNotifications'] = async () => {
  const response = (await NativeModule.checkNotifications()) as NotificationsResponse;
  return response;
};

const checkMultiple: Contract['checkMultiple'] = async (permissions) => {
  const output: Record<string, PermissionStatus> = {};

  for (const permission of uniq(permissions)) {
    output[permission] = await check(permission);
  }

  return output as Awaited<ReturnType<Contract['checkMultiple']>>;
};

const requestMultiple: Contract['requestMultiple'] = async (permissions) => {
  const output: Record<string, PermissionStatus> = {};

  for (const permission of uniq(permissions)) {
    output[permission] = await request(permission);
  }

  return output as Awaited<ReturnType<Contract['requestMultiple']>>;
};

export const methods: Contract = {
  canScheduleExactAlarms,
  canUseFullScreenIntent,
  check,
  checkLocationAccuracy,
  checkMultiple,
  checkNotifications,
  openPhotoPicker,
  openSettings,
  request,
  requestLocationAccuracy,
  requestMultiple,
  requestNotifications: checkNotifications,
};
