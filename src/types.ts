import {ANDROID, IOS, RESULTS} from './constants';

type Values<T extends object> = T[keyof T];

export {Rationale} from 'react-native';

export type AndroidPermission = Values<typeof ANDROID>;
export type IOSPermission = Values<typeof IOS>;
export type Permission = AndroidPermission | IOSPermission;

export type PermissionStatus = Values<typeof RESULTS>;

export type LocationAccuracyOptions = {
  purposeKey: string;
};

export type LocationAccuracy = 'full' | 'reduced';

export type NotificationOption =
  | 'alert'
  | 'badge'
  | 'sound'
  | 'carPlay'
  | 'criticalAlert'
  | 'provisional';

export type NotificationSettings = {
  alert?: boolean;
  badge?: boolean;
  sound?: boolean;
  carPlay?: boolean;
  criticalAlert?: boolean;
  provisional?: boolean;
  lockScreen?: boolean;
  notificationCenter?: boolean;
};

export type NotificationsResponse = {
  status: PermissionStatus;
  settings: NotificationSettings;
};
