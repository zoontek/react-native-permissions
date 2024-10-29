import {Alert, Platform} from 'react-native';
import NativeModule from './NativeRNPermissions';
import type {Contract} from './contract';
import type {NotificationsResponse, Permission, PermissionStatus, Rationale} from './types';
import {
  checkLocationAccuracy,
  openPhotoPicker,
  requestLocationAccuracy,
} from './unsupportedMethods';
import {uniq} from './utils';

const POST_NOTIFICATIONS = 'android.permission.POST_NOTIFICATIONS' as Permission;
const USES_LEGACY_NOTIFICATIONS = (Platform.OS === 'android' ? Platform.Version : 0) < 33;

const shouldRequestPermission = async (
  permission: Permission,
  rationale: Rationale | undefined,
): Promise<boolean> => {
  if (rationale == null || !(await NativeModule.shouldShowRequestRationale(permission))) {
    return true;
  }

  if (typeof rationale === 'function') {
    return rationale();
  }

  return new Promise<boolean>((resolve) => {
    const {buttonNegative} = rationale;

    Alert.alert(
      rationale.title,
      rationale.message,
      [
        ...(buttonNegative ? [{text: buttonNegative, onPress: () => resolve(false)}] : []),
        {text: rationale.buttonPositive, onPress: () => resolve(true)},
      ],
      {cancelable: false},
    );
  });
};

const openSettings: Contract['openSettings'] = async (type = 'application') => {
  await NativeModule.openSettings(type);
};

const canScheduleExactAlarms: Contract['canScheduleExactAlarms'] = () =>
  NativeModule.canScheduleExactAlarms();

const check: Contract['check'] = async (permission) => {
  const status = (await NativeModule.check(permission)) as PermissionStatus;
  return status;
};

const request: Contract['request'] = async (permission, rationale) => {
  const fn = (await shouldRequestPermission(permission, rationale))
    ? NativeModule.request
    : NativeModule.check;

  const status = (await fn(permission)) as PermissionStatus;
  return status;
};

const checkNotifications: Contract['checkNotifications'] = async () => {
  if (USES_LEGACY_NOTIFICATIONS) {
    const response = (await NativeModule.checkNotifications()) as NotificationsResponse;
    return response;
  } else {
    const status = await check(POST_NOTIFICATIONS);
    return {status, settings: {}};
  }
};

const requestNotifications: Contract['requestNotifications'] = async (options, rationale) => {
  if (USES_LEGACY_NOTIFICATIONS) {
    const response = (await NativeModule.requestNotifications(options)) as NotificationsResponse;
    return response;
  } else {
    const status = await request(POST_NOTIFICATIONS, rationale);
    return {status, settings: {}};
  }
};

const checkMultiple: Contract['checkMultiple'] = (permissions) => {
  return NativeModule.checkMultiple(uniq(permissions)) as ReturnType<Contract['checkMultiple']>;
};

const requestMultiple: Contract['requestMultiple'] = (permissions) => {
  return NativeModule.requestMultiple(uniq(permissions)) as ReturnType<Contract['requestMultiple']>;
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
