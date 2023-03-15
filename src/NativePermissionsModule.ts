import {TurboModule, TurboModuleRegistry} from 'react-native';

type NotificationsResponse = {
  status: Object;
  settings: Object;
};

export interface Spec extends TurboModule {
  checkNotifications(): Promise<NotificationsResponse>;
  openSettings(): Promise<void>;

  // Android only part
  checkMultiplePermissions(permissions: string[]): Promise<Object>;
  checkPermission(permission: string): Promise<string>;
  requestMultiplePermissions(permissions: string[]): Promise<Object>;
  requestPermission(permission: string): Promise<string>;
  shouldShowRequestPermissionRationale(permission: string): Promise<boolean>;

  // iOS only part
  check(permission: string): Promise<string>; // TODO: should be number prolly
  checkLocationAccuracy(): Promise<string>;
  getConstants(): {available?: string[]};
  openLimitedPhotoLibraryPicker(): Promise<boolean>;
  request(permission: string): Promise<string>; // TODO: should be number prolly
  requestLocationAccuracy(purposeKey: string): Promise<string>;
  requestNotifications(options: string[]): Promise<NotificationsResponse>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNPermissionsModule');
