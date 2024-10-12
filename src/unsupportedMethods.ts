import type {Contract} from './contract';

const ONLY_SUPPORTED_BY_IOS_14 = 'Only supported by iOS 14 and above';

export const checkLocationAccuracy: Contract['checkLocationAccuracy'] = async () => {
  throw new Error(ONLY_SUPPORTED_BY_IOS_14);
};

export const openPhotoPicker: Contract['openPhotoPicker'] = async () => {
  throw new Error(ONLY_SUPPORTED_BY_IOS_14);
};

export const requestLocationAccuracy: Contract['requestLocationAccuracy'] = async () => {
  throw new Error(ONLY_SUPPORTED_BY_IOS_14);
};
