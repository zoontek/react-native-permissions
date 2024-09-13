import {Alert, Platform} from 'react-native';
import NativeModule from './NativeRNPermissions';
import type {Contract} from './contract';
import {RESULTS} from './results';
import type {Permission, PermissionStatus, Rationale} from './types';
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

const openSettings: Contract['openSettings'] = async () => {
  await NativeModule.openSettings();
};

const check: Contract['check'] = (permission) => {
  return NativeModule.check(permission);
};

const request: Contract['request'] = async (permission, rationale) => {
  const performRequest = await shouldRequestPermission(permission, rationale);

  if (!performRequest) {
    const granted = await check(permission);
    return granted ? RESULTS.GRANTED : RESULTS.DENIED;
  }

  const status = (await NativeModule.request(permission)) as PermissionStatus;
  return status;
};

const checkNotifications: Contract['checkNotifications'] = async () => {
  return USES_LEGACY_NOTIFICATIONS
    ? NativeModule.checkNotifications()
    : {granted: await check(POST_NOTIFICATIONS), settings: {}};
};

const requestNotifications: Contract['requestNotifications'] = async (options, rationale) => {
  if (USES_LEGACY_NOTIFICATIONS) {
    return NativeModule.requestNotifications(options) as ReturnType<
      Contract['requestNotifications']
    >;
  }

  const performRequest = await shouldRequestPermission(POST_NOTIFICATIONS, rationale);

  if (!performRequest) {
    const granted = await check(POST_NOTIFICATIONS);
    return {status: granted ? RESULTS.GRANTED : RESULTS.DENIED, settings: {}};
  }

  const status = await request(POST_NOTIFICATIONS);
  return {status, settings: {}};
};

const checkMultiple: Contract['checkMultiple'] = (permissions) => {
  return NativeModule.checkMultiple(uniq(permissions)) as ReturnType<Contract['checkMultiple']>;
};

const requestMultiple: Contract['requestMultiple'] = (permissions) => {
  return NativeModule.requestMultiple(uniq(permissions)) as ReturnType<Contract['requestMultiple']>;
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
