import type {Contract} from './contract';
import {RESULTS} from './results';
import type {NotificationsResponse, Permission, PermissionStatus} from './types';
import {
  checkLocationAccuracy,
  openLimitedPhotoLibraryPicker,
  requestLocationAccuracy,
} from './unsupportedPlatformMethods';

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

export const methods: Contract = {
  check,
  checkLocationAccuracy,
  checkMultiple,
  checkNotifications,
  openLimitedPhotoLibraryPicker,
  openSettings: Promise.reject,
  request: check,
  requestLocationAccuracy,
  requestMultiple: checkMultiple,
  requestNotifications: checkNotifications,
};
