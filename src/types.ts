import type {AndroidPermissionMap} from './permissions.android';
import type {IOSPermissionMap} from './permissions.ios';
import type {WindowsPermissionMap} from './permissions.windows';
import {ResultMap} from './results';

type Values<T extends object> = T[keyof T];

export type AndroidPermission = Values<AndroidPermissionMap>;
export type IOSPermission = Values<IOSPermissionMap>;
export type WindowsPermission = Values<WindowsPermissionMap>;
export type Permission = AndroidPermission | IOSPermission | WindowsPermission;
export type PermissionStatus = Values<ResultMap>;

export type RationaleObject = {
  title: string;
  message: string;
  buttonPositive: string;
  buttonNegative?: string;
};

export type Rationale = RationaleObject | (() => Promise<boolean>);

export type LocationAccuracy = 'full' | 'reduced';
export type LocationAccuracyOptions = {purposeKey: string};

export type NotificationOption =
  | 'alert'
  | 'badge'
  | 'sound'
  | 'carPlay'
  | 'criticalAlert'
  | 'provisional'
  | 'providesAppSettings';

export type NotificationSettings = {
  alert?: boolean;
  badge?: boolean;
  sound?: boolean;
  carPlay?: boolean;
  criticalAlert?: boolean;
  provisional?: boolean;
  providesAppSettings?: boolean;
  lockScreen?: boolean;
  notificationCenter?: boolean;
};
