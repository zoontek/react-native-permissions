import {Alert, AlertButton, NativeModules} from 'react-native';
import type {Contract} from './contract';
import type {NotificationsResponse, Permission, PermissionStatus, Rationale} from './types';
import {
  checkLocationAccuracy,
  openLimitedPhotoLibraryPicker,
  requestLocationAccuracy,
} from './unsupportedPlatformMethods';
import {uniq} from './utils';

const NativeModule: {
  checkPermission: (permission: Permission) => Promise<PermissionStatus>;
  requestPermission: (permission: Permission) => Promise<PermissionStatus>;
  checkNotifications: () => Promise<NotificationsResponse>;
  openSettings: () => Promise<true>;
  shouldShowRequestPermissionRationale: (permission: Permission) => Promise<boolean>;

  checkMultiplePermissions: (
    permissions: Permission[],
  ) => Promise<Record<Permission, PermissionStatus>>;
  requestMultiplePermissions: (
    permissions: Permission[],
  ) => Promise<Record<Permission, PermissionStatus>>;
} = NativeModules.RNPermissions;

async function openSettings(): Promise<void> {
  await NativeModule.openSettings();
}

function check(permission: Permission): Promise<PermissionStatus> {
  return NativeModule.checkPermission(permission);
}

async function request(permission: Permission, rationale?: Rationale): Promise<PermissionStatus> {
  if (rationale) {
    const shouldShowRationale = await NativeModule.shouldShowRequestPermissionRationale(permission);

    if (shouldShowRationale) {
      const {title, message, buttonPositive, buttonNegative, buttonNeutral} = rationale;

      return new Promise((resolve) => {
        const buttons: AlertButton[] = [];

        if (buttonNegative) {
          const onPress = () => resolve(NativeModule.checkPermission(permission));
          buttonNeutral && buttons.push({text: buttonNeutral, onPress});
          buttons.push({text: buttonNegative, onPress});
        }

        buttons.push({
          text: buttonPositive,
          onPress: () => resolve(NativeModule.requestPermission(permission)),
        });

        Alert.alert(title, message, buttons, {cancelable: false});
      });
    }
  }

  return NativeModule.requestPermission(permission);
}

function checkNotifications(): Promise<NotificationsResponse> {
  return NativeModule.checkNotifications();
}

function checkMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const dedup = uniq(permissions);
  return NativeModule.checkMultiplePermissions(dedup);
}

function requestMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  const dedup = uniq(permissions);
  return NativeModule.requestMultiplePermissions(dedup);
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
  requestNotifications: checkNotifications,
};
