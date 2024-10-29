import type {Contract} from './contract';

const getUnsupportedError = (os: 'iOS' | 'Android', version: number) =>
  new Error(`Only supported by ${os} ${version} and above`);

export const canScheduleExactAlarms: Contract['canScheduleExactAlarms'] = async () => {
  throw getUnsupportedError('Android', 12);
};

export const openPhotoPicker: Contract['openPhotoPicker'] = async () => {
  throw getUnsupportedError('iOS', 14);
};

export const requestLocationAccuracy: Contract['requestLocationAccuracy'] = async () => {
  throw getUnsupportedError('iOS', 14);
};

export const checkLocationAccuracy: Contract['checkLocationAccuracy'] = async () => {
  throw getUnsupportedError('iOS', 14);
};
