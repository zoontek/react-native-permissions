import {
  NotificationOption,
  NotificationsResponse,
  Permission,
  PermissionStatus,
  Rationale,
} from './types';

export interface Contract {
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

  checkMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;

  requestMultiple<P extends Permission[]>(
    permissions: P,
  ): Promise<Record<P[number], PermissionStatus>>;
}
