import {ANDROID, IOS, PERMISSIONS, RESULTS} from './constants';
import {Rationale} from 'react-native';

export {Rationale} from 'react-native';

type Values<T extends object> = T[keyof T];

export type AndroidPermission = Values<typeof ANDROID>;
export type IOSPermission = Values<typeof IOS>;
export type Permission = AndroidPermission | IOSPermission;

export type PermissionStatus = Values<typeof RESULTS>;

export interface FullAccuracyOptionsIOS {
  temporaryPurposeKey: string;
}
export type RequestOptions<
  T extends Permission = Permission
> = T extends typeof PERMISSIONS.IOS.LOCATION_FULL_ACCURACY
  ? FullAccuracyOptionsIOS
  : Rationale;

export type NotificationOption =
  | 'alert'
  | 'badge'
  | 'sound'
  | 'carPlay'
  | 'criticalAlert'
  | 'provisional';

export interface NotificationSettings {
  alert?: boolean;
  badge?: boolean;
  sound?: boolean;
  carPlay?: boolean;
  criticalAlert?: boolean;
  lockScreen?: boolean;
  notificationCenter?: boolean;
}

export interface NotificationsResponse {
  status: PermissionStatus;
  settings: NotificationSettings;
}
