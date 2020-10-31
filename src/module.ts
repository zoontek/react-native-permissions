import type {Contract} from './contract';
import {RESULTS} from './results';
import type {NotificationsResponse, Permission, PermissionStatus} from './types';

async function check(): Promise<PermissionStatus> {
  return RESULTS.UNAVAILABLE;
}

async function checkNotifications(): Promise<NotificationsResponse> {
  return {status: RESULTS.UNAVAILABLE, settings: {}};
}

async function checkMultiple<P extends Permission[]>(
  permissions: P,
): Promise<Record<P[number], PermissionStatus>> {
  return permissions.reduce((acc, permission: P[number]) => {
    acc[permission] = RESULTS.UNAVAILABLE;
    return acc;
  }, {} as Record<P[number], PermissionStatus>);
}

export const module: Contract = {
  check,
  checkLocationAccuracy: Promise.reject,
  checkMultiple,
  checkNotifications,
  openLimitedPhotoLibraryPicker: Promise.reject,
  openSettings: Promise.reject,
  request: check,
  requestLocationAccuracy: Promise.reject,
  requestMultiple: checkMultiple,
  requestNotifications: checkNotifications,
};
