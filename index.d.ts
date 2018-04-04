type PermissionType = 'location' | 'camera' | 'microphone' | 'photo' | 'contacts' | 'event';
export type Response = 'authorized' | 'denied' | 'restricted' | 'undetermined';

export function check(permission: PermissionType): Promise<Response>;
export function request(permission: PermissionType): Promise<Response>;
export function openSettings(): void;