import type {Contract} from './contract';
import NativeModule from './NativeRNPermissions';
import {LocationAccuracy, NotificationsResponse, PermissionStatus} from './types';
import {canScheduleExactAlarms} from './unsupportedMethods';
import {uniq} from './utils';

const openPhotoPicker: Contract['openPhotoPicker'] = async () => {
  await NativeModule.openPhotoPicker();
};

const openSettings: Contract['openSettings'] = async (type = 'application') => {
  await NativeModule.openSettings(type);
};

const check: Contract['check'] = async (permission) => {
  const status = (await NativeModule.check(permission)) as PermissionStatus;
  return status;
};

const request: Contract['request'] = async (permission) => {
  const status = (await NativeModule.request(permission)) as PermissionStatus;
  return status;
};

const checkLocationAccuracy: Contract['checkLocationAccuracy'] = async () => {
  const accuracy = (await NativeModule.checkLocationAccuracy()) as LocationAccuracy;
  return accuracy;
};

const requestLocationAccuracy: Contract['requestLocationAccuracy'] = async ({purposeKey}) => {
  const accuracy = (await NativeModule.requestLocationAccuracy(purposeKey)) as LocationAccuracy;
  return accuracy;
};

const checkNotifications: Contract['checkNotifications'] = async () => {
  const response = (await NativeModule.checkNotifications()) as NotificationsResponse;
  return response;
};

const requestNotifications: Contract['requestNotifications'] = async (options) => {
  const response = (await NativeModule.requestNotifications(options)) as NotificationsResponse;
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
