import type {Contract} from './contract';
import NativeModule from './NativeRNPermissions';
import {uniq} from './utils';

const openPhotoPicker: Contract['openPhotoPicker'] = async () => {
  await NativeModule.openPhotoPicker();
};

const openSettings: Contract['openSettings'] = async () => {
  await NativeModule.openSettings();
};

const check: Contract['check'] = (permission) => {
  return NativeModule.check(permission);
};

const request: Contract['request'] = async (permission) => {
  return NativeModule.request(permission) as ReturnType<Contract['request']>;
};

const checkLocationAccuracy: Contract['checkLocationAccuracy'] = async () => {
  return NativeModule.checkLocationAccuracy() as ReturnType<Contract['checkLocationAccuracy']>;
};

const requestLocationAccuracy: Contract['requestLocationAccuracy'] = ({purposeKey}) => {
  return NativeModule.requestLocationAccuracy(purposeKey) as ReturnType<
    Contract['requestLocationAccuracy']
  >;
};

const checkNotifications: Contract['checkNotifications'] = async () => {
  return NativeModule.checkNotifications();
};

const requestNotifications: Contract['requestNotifications'] = (options) => {
  return NativeModule.requestNotifications(options) as ReturnType<Contract['requestNotifications']>;
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
