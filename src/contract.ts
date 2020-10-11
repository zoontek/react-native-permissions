import {
  LocationAccuracy,
  LocationAccuracyOptions,
  NotificationOption,
  NotificationsResponse,
  Permission,
  PermissionStatus,
  Rationale,
} from './types';

export type Contract = {
  openLimitedPhotoLibraryPicker(): Promise<void>;
  openSettings(): Promise<void>;

  check(permission: Permission): Promise<PermissionStatus>;

  request(
    permission: Permission,
    rationale?: Rationale,
  ): Promise<PermissionStatus>;

  checkNotifications(): Promise<NotificationsResponse>;

  requestNotifications(
    options: NotificationOption[],
  ): Promise<NotificationsResponse>;

  checkLocationAccuracy(): Promise<LocationAccuracy>;

  requestLocationAccuracy(
    options: LocationAccuracyOptions,
  ): Promise<LocationAccuracy>;

  checkMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;

  requestMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;
};
