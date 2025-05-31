import type {AndroidPermissionMap} from './permissions.android';
import type {IOSPermissionMap} from './permissions.ios';
import type {WindowsPermissionMap} from './permissions.windows';
import {proxifyPermissions} from './utils';

export const PERMISSIONS = Object.freeze({
  ANDROID: proxifyPermissions<AndroidPermissionMap>('android'),
  IOS: proxifyPermissions<IOSPermissionMap>('ios'),
  WINDOWS: proxifyPermissions<WindowsPermissionMap>('windows'),
} as const);
