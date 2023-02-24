/* eslint-disable @typescript-eslint/ban-types */
// we use Object type because methods on the native side use NSDictionary and ReadableMap
// and we want to stay compatible with those
import {TurboModule, TurboModuleRegistry} from 'react-native';

type NotificationsResponse = {
  status: Object;
  settings: Object;
};

export interface Spec extends TurboModule {
  openSettings(): Promise<void>;
  checkNotifications(): Promise<NotificationsResponse>;

  // Android only part
  checkPermission(permission: string): Promise<string>;
  shouldShowRequestPermissionRationale(permission: string): Promise<boolean>;
  requestPermission(permission: string): Promise<string>;
  checkMultiplePermissions(permissions: string[]): Promise<Object>;
  requestMultiplePermissions(permissions: string[]): Promise<Object>;

  // iOS only part
  check(permission: string): Promise<string>; // TODO: should be number prolly
  checkLocationAccuracy(): Promise<string>;
  request(permission: string): Promise<string>; // TODO: should be number prolly
  requestLocationAccuracy(purposeKey: string): Promise<string>;
  requestNotifications(options: string[]): Promise<NotificationsResponse>;
  openLimitedPhotoLibraryPicker(): Promise<boolean>;
  getConstants(): {available?: string[]};
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNPermissionsModule');
