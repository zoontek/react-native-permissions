import type {TurboModule} from 'react-native';
import {TurboModuleRegistry} from 'react-native';

export interface Spec extends TurboModule {
  check(permission: string): Promise<boolean>;
  checkLocationAccuracy(): Promise<string>;
  checkMultiple(permissions: string[]): Promise<Object>;
  checkNotifications(): Promise<{granted: boolean; settings: Object}>;
  openPhotoPicker(): Promise<boolean>;
  openSettings(): Promise<void>;
  request(permission: string): Promise<string>;
  requestLocationAccuracy(purposeKey: string): Promise<string>;
  requestMultiple(permissions: string[]): Promise<Object>;
  requestNotifications(options: string[]): Promise<{status: string; settings: Object}>;
  shouldShowRequestRationale(permission: string): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('RNPermissions');
