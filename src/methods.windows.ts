import {NativeModules} from 'react-native';
import type {Contract} from './contract';
import {RESULTS} from './results';
import type {Permission, PermissionStatus} from './types';
import {
  checkLocationAccuracy,
  openPhotoPicker,
  requestLocationAccuracy,
} from './unsupportedMethods';
import {uniq} from './utils';

const NativeModule: {
  Check: (permission: Permission) => PermissionStatus;
  CheckNotifications: () => Promise<PermissionStatus>;
  Request: (permission: Permission) => Promise<PermissionStatus>;
  OpenSettings: () => Promise<void>;
} = NativeModules.RNPermissions;

const openSettings: Contract['openSettings'] = async () => {
  await NativeModule.OpenSettings();
};

const check: Contract['check'] = (permission) => {
  return NativeModule.Check(permission) === RESULTS.GRANTED;
};

const request: Contract['request'] = (permission) => {
  return NativeModule.Request(permission);
};

const checkNotifications: Contract['checkNotifications'] = async () => {
  const status = await NativeModule.CheckNotifications();
  return {granted: status === RESULTS.GRANTED, settings: {}};
};

const requestNotifications: Contract['requestNotifications'] = async () => {
  const status = await NativeModule.CheckNotifications();
  return {status, settings: {}};
};

const checkMultiple: Contract['checkMultiple'] = (permissions) => {
  const output: Record<string, boolean> = {};

  for (const permission of uniq(permissions)) {
    output[permission] = check(permission);
  }

  return output as ReturnType<Contract['checkMultiple']>;
};

const requestMultiple: Contract['requestMultiple'] = async (permissions) => {
  const output: Record<string, string> = {};

  for (const permission of uniq(permissions)) {
    output[permission] = await request(permission);
  }

  return output as Awaited<ReturnType<Contract['requestMultiple']>>;
};

export const methods: Contract = {
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
