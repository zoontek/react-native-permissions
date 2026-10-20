// Keep in sync with `permissions_frameworks` in scripts/setup.rb
export const iosPermissionFrameworks = {
  AppTrackingTransparency: ['AdSupport', 'AppTrackingTransparency'],
  Bluetooth: ['CoreBluetooth'],
  Calendars: ['EventKit'],
  CalendarsWriteOnly: ['EventKit'],
  Camera: ['AVFoundation'],
  Contacts: ['Contacts', 'ContactsUI'],
  FaceID: ['LocalAuthentication'],
  LocationAccuracy: ['CoreLocation'],
  LocationAlways: ['CoreLocation'],
  LocationWhenInUse: ['CoreLocation'],
  MediaLibrary: ['MediaPlayer'],
  Microphone: ['AVFoundation'],
  Motion: ['CoreMotion'],
  Notifications: ['UserNotifications'],
  PhotoLibrary: ['Photos', 'PhotosUI'],
  PhotoLibraryAddOnly: ['Photos'],
  Reminders: ['EventKit'],
  Siri: ['Intents'],
  SpeechRecognition: ['Speech'],
  StoreKit: ['StoreKit'],
} as const satisfies Record<string, readonly string[]>;

export type IosPermission = keyof typeof iosPermissionFrameworks;

export const iosPermissions = Object.keys(iosPermissionFrameworks) as IosPermission[];

export const isIosPermission = (name: string): name is IosPermission =>
  (iosPermissions as readonly string[]).includes(name);
