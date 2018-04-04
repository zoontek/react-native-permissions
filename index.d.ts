export function check(
  permission: 'location' | 'camera' | 'microphone' | 'photo' | 'contacts' | 'event',
): Promise<'authorized' | 'denied' | 'restricted' | 'undetermined'>;
