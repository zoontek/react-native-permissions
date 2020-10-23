import {ANDROID, IOS, WINDOWS, RESULTS} from './constants';

type Values<T extends object> = T[keyof T];

export {Rationale} from 'react-native';

export type AndroidPermission = Values<typeof ANDROID>;
export type IOSPermission = Values<typeof IOS>;
export type WindowsPermission = Values<typeof WINDOWS>;
export type Permission = AndroidPermission | IOSPermission | WindowsPermission;

export type PermissionStatus = Values<typeof RESULTS>;

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
