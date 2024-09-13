import type {Contract} from './contract';
import {RESULTS} from './results';
import {
  checkLocationAccuracy,
  openPhotoPicker,
  requestLocationAccuracy,
} from './unsupportedMethods';

const openSettings: Contract['openSettings'] = async () => {};

const check: Contract['check'] = async () => {
  return false;
};

const request: Contract['request'] = async () => {
  return RESULTS.BLOCKED;
};

const checkNotifications: Contract['checkNotifications'] = async () => {
  return {granted: false, settings: {}};
};

const requestNotifications: Contract['requestNotifications'] = async () => {
  return {status: RESULTS.BLOCKED, settings: {}};
};

const checkMultiple: Contract['checkMultiple'] = async (permissions) => {
  const output: Record<string, boolean> = {};

  for (const permission of permissions) {
    output[permission] = false;
  }

  return output as Awaited<ReturnType<Contract['checkMultiple']>>;
};

const requestMultiple: Contract['requestMultiple'] = async (permissions) => {
  const output: Record<string, string> = {};

  for (const permission of permissions) {
    output[permission] = RESULTS.BLOCKED;
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
