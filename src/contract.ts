import {IOS} from './constants';
import {
  AndroidPermission,
  IOSPermission,
  NotificationOption,
  NotificationsResponse,
  Permission,
  PermissionStatus,
  RationaleAndroid,
  RationaleFullAccuracyIOS,
} from './types';

export interface Contract {
  openSettings(): Promise<void>;

  check(permission: Permission): Promise<PermissionStatus>;

  request(
    permission: AndroidPermission,
    rationale?: RationaleAndroid,
  ): Promise<PermissionStatus>;
  request(
    permission: Exclude<IOSPermission, typeof IOS.LOCATION_FULL_ACCURACY>,
  ): Promise<PermissionStatus>;
  request(
    permission: typeof IOS.LOCATION_FULL_ACCURACY,
    rationale: RationaleFullAccuracyIOS,
  ): Promise<PermissionStatus>;

  checkNotifications(): Promise<NotificationsResponse>;

  requestNotifications(
    options: NotificationOption[],
  ): Promise<NotificationsResponse>;

  checkMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;

  requestMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;
}
