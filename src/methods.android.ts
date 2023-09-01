import {Alert, AlertButton} from 'react-native';
import NativeModule from './NativePermissionsModule';
import type {Contract} from './contract';
import type {NotificationsResponse, Permission, PermissionStatus, Rationale} from './types';
import {
  checkLocationAccuracy,
  openLimitedPhotoLibraryPicker,
  requestLocationAccuracy,
} from './unsupportedPlatformMethods';
import {platformVersion, uniq} from './utils';

const TIRAMISU_VERSION_CODE = 33;

async function openSettings(): Promise<void> {
  await NativeModule.openSettings();
}

function check(permission: Permission): Promise<PermissionStatus> {
  return NativeModule.checkPermission(permission) as Promise<PermissionStatus>;
}

async function showRationaleAlert(rationale: Rationale): Promise<boolean> {
  return new Promise<boolean>((resolve) => {
    const {title, message, buttonPositive, buttonNegative, buttonNeutral} = rationale;
    const buttons: AlertButton[] = [];

    if (buttonNegative) {
      const onPress = () => resolve(false);
      buttonNeutral && buttons.push({text: buttonNeutral, onPress});
      buttons.push({text: buttonNegative, onPress});
    }

    buttons.push({text: buttonPositive, onPress: () => resolve(true)});
    Alert.alert(title, message, buttons, {cancelable: false});
  });
}

async function request(
  permission: Permission,
  rationale?: Rationale | (() => Promise<boolean>),
): Promise<PermissionStatus> {
  if (rationale == null || !(await NativeModule.shouldShowRequestPermissionRationale(permission))) {
    return NativeModule.requestPermission(permission) as Promise<PermissionStatus>;
  }

  return (typeof rationale === 'function' ? rationale() : showRationaleAlert(rationale)).then(
    (shouldRequestPermission) =>
      (shouldRequestPermission
        ? NativeModule.requestPermission(permission)
        : NativeModule.checkPermission(permission)) as Promise<PermissionStatus>,
  );
}

async function checkNotifications(): Promise<NotificationsResponse> {
  if (platformVersion < TIRAMISU_VERSION_CODE) {
    return NativeModule.checkNotifications() as Promise<NotificationsResponse>;
  }

  const status = await check('android.permission.POST_NOTIFICATIONS');
  return {status, settings: {}};
}

async function requestNotifications(): Promise<NotificationsResponse> {
  if (platformVersion < TIRAMISU_VERSION_CODE) {
    return NativeModule.checkNotifications() as Promise<NotificationsResponse>;
  }

  const status = await request('android.permission.POST_NOTIFICATIONS');
  return {status, settings: {}};
}

function checkMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const dedup = uniq(permissions);
  return NativeModule.checkMultiplePermissions(dedup) as Promise<
    Record<P[number], PermissionStatus>
  >;
}

function requestMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const dedup = uniq(permissions);
  return NativeModule.requestMultiplePermissions(dedup) as Promise<
    Record<P[number], PermissionStatus>
  >;
}

export const methods: Contract = {
  check,
  checkLocationAccuracy,
  checkMultiple,
  checkNotifications,
  openLimitedPhotoLibraryPicker,
  openSettings,
  request,
  requestLocationAccuracy,
  requestMultiple,
  requestNotifications,
};
