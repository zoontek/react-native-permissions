type PermissionType = 'location' | 'camera' | 'microphone' | 'photo' | 'contacts' | 'event';

export function check(
  permission: PermissionType,
): Promise<'authorized' | 'denied' | 'restricted' | 'undetermined'>;
export function request(
  permission: PermissionType,
): Promise<'authorized' | 'denied' | 'restricted' | 'undetermined'>;
export function openSettings(): void;