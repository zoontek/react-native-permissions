import {TurboModule, TurboModuleRegistry} from 'react-native';

type NotificationsResponse = {
  status: Object;
  settings: Object;
};

export interface Spec extends TurboModule {
  check(permission: string): Promise<string>;
  checkNotifications(): Promise<NotificationsResponse>;
  getConstants(): {available?: string[]};
  openSettings(): Promise<void>;
  request(permission: string): Promise<string>;

  // Android only part
  checkMultiple(permissions: string[]): Promise<Object>;
  requestMultiple(permissions: string[]): Promise<Object>;
  shouldShowRequestRationale(permission: string): Promise<boolean>;

  // iOS only part
  checkLocationAccuracy(): Promise<string>;
  openPhotoPicker(): Promise<boolean>;
  requestLocationAccuracy(purposeKey: string): Promise<string>;
  requestNotifications(options: string[]): Promise<NotificationsResponse>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNPermissionsModule');
