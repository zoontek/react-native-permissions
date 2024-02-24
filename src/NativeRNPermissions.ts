import type {TurboModule} from 'react-native';
import {TurboModuleRegistry} from 'react-native';

type NotificationsResponse = {
  status: Object;
  settings: Object;
};

export interface Spec extends TurboModule {
  getConstants(): {
    available: string[];
  };

  openSettings(): Promise<void>;
  check(permission: string): Promise<string>;
  checkNotifications(): Promise<NotificationsResponse>;
  request(permission: string): Promise<string>;
  requestNotifications(options: string[]): Promise<NotificationsResponse>;

  // Android only part
  checkMultiple(permissions: string[]): Promise<Object>;
  requestMultiple(permissions: string[]): Promise<Object>;
  shouldShowRequestRationale(permission: string): Promise<boolean>;

  // iOS only part
  checkLocationAccuracy(): Promise<string>;
  openPhotoPicker(): Promise<boolean>;
  requestLocationAccuracy(purposeKey: string): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNPermissions');
