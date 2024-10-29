import type {
  LocationAccuracy,
  LocationAccuracyOptions,
  NotificationOption,
  NotificationsResponse,
  Permission,
  PermissionStatus,
  Rationale,
} from './types';

export type Contract = {
  canScheduleExactAlarms(): Promise<boolean>;
  check(permission: Permission): Promise<PermissionStatus>;
  checkLocationAccuracy(): Promise<LocationAccuracy>;
  checkMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;
  checkNotifications(): Promise<NotificationsResponse>;
  openPhotoPicker(): Promise<void>;
  openSettings(type?: 'application' | 'alarms' | 'notifications'): Promise<void>;
  request(permission: Permission, rationale?: Rationale): Promise<PermissionStatus>;
  requestLocationAccuracy(options: LocationAccuracyOptions): Promise<LocationAccuracy>;
  requestMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;
  requestNotifications(
    options: NotificationOption[],
    rationale?: Rationale,
  ): Promise<NotificationsResponse>;
};
