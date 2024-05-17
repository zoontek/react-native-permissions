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
  check(permission: Permission): Promise<PermissionStatus>;
  checkLocationAccuracy(): Promise<LocationAccuracy>;
  checkNotifications(): Promise<NotificationsResponse>;
  openLimitedPhotoLibraryPicker(): Promise<void>;
  openSettings(): Promise<void>;
  request(permission: Permission, rationale?: Rationale): Promise<PermissionStatus>;
  requestLocationAccuracy(options: LocationAccuracyOptions): Promise<LocationAccuracy>;
  requestNotifications(options: NotificationOption[]): Promise<NotificationsResponse>;

  checkMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;
  requestMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;
};
