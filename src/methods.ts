import type {Contract} from './contract';
import {RESULTS} from './results';
import {PermissionStatus} from './types';
import {
  checkLocationAccuracy,
  openPhotoPicker,
  requestLocationAccuracy,
} from './unsupportedMethods';

const check: Contract['check'] = async () => {
  return RESULTS.UNAVAILABLE;
};

const checkNotifications: Contract['checkNotifications'] = async () => {
  return {status: RESULTS.UNAVAILABLE, settings: {}};
};

const checkMultiple: Contract['checkMultiple'] = async (permissions) => {
  const output: Record<string, PermissionStatus> = {};

  for (const permission of permissions) {
    output[permission] = RESULTS.UNAVAILABLE;
  }

  return output as Awaited<ReturnType<Contract['checkMultiple']>>;
};

export const methods: Contract = {
  canScheduleExactAlarms: Promise.reject,
  check,
  checkLocationAccuracy,
  checkMultiple,
  checkNotifications,
  openPhotoPicker,
  openSettings: Promise.reject,
  request: check,
  requestLocationAccuracy,
  requestMultiple: checkMultiple,
  requestNotifications: checkNotifications,
};
