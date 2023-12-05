import type {IOSPermissionMap} from './permissions.ios';
import type {WindowsPermissionMap} from './permissions.windows';

const ANDROID = Object.freeze({
  ACCEPT_HANDOVER: 'android.permission.ACCEPT_HANDOVER',
  ACCESS_BACKGROUND_LOCATION: 'android.permission.ACCESS_BACKGROUND_LOCATION',
  ACCESS_COARSE_LOCATION: 'android.permission.ACCESS_COARSE_LOCATION',
  ACCESS_FINE_LOCATION: 'android.permission.ACCESS_FINE_LOCATION',
  ACCESS_MEDIA_LOCATION: 'android.permission.ACCESS_MEDIA_LOCATION',
  ACTIVITY_RECOGNITION: 'android.permission.ACTIVITY_RECOGNITION',
  ADD_VOICEMAIL: 'com.android.voicemail.permission.ADD_VOICEMAIL',
  ANSWER_PHONE_CALLS: 'android.permission.ANSWER_PHONE_CALLS',
  BLUETOOTH_ADVERTISE: 'android.permission.BLUETOOTH_ADVERTISE',
  BLUETOOTH_CONNECT: 'android.permission.BLUETOOTH_CONNECT',
  BLUETOOTH_SCAN: 'android.permission.BLUETOOTH_SCAN',
  BODY_SENSORS: 'android.permission.BODY_SENSORS',
  BODY_SENSORS_BACKGROUND: 'android.permission.BODY_SENSORS_BACKGROUND',
  CALL_PHONE: 'android.permission.CALL_PHONE',
  CAMERA: 'android.permission.CAMERA',
  GET_ACCOUNTS: 'android.permission.GET_ACCOUNTS',
  NEARBY_WIFI_DEVICES: 'android.permission.NEARBY_WIFI_DEVICES',
  POST_NOTIFICATIONS: 'android.permission.POST_NOTIFICATIONS',
  PROCESS_OUTGOING_CALLS: 'android.permission.PROCESS_OUTGOING_CALLS',
  READ_CALENDAR: 'android.permission.READ_CALENDAR',
  READ_CALL_LOG: 'android.permission.READ_CALL_LOG',
  READ_CONTACTS: 'android.permission.READ_CONTACTS',
  READ_EXTERNAL_STORAGE: 'android.permission.READ_EXTERNAL_STORAGE',
  READ_MEDIA_AUDIO: 'android.permission.READ_MEDIA_AUDIO',
  READ_MEDIA_IMAGES: 'android.permission.READ_MEDIA_IMAGES',
  READ_MEDIA_VIDEO: 'android.permission.READ_MEDIA_VIDEO',
  READ_MEDIA_VISUAL_USER_SELECTED: 'android.permission.READ_MEDIA_VISUAL_USER_SELECTED',
  READ_PHONE_NUMBERS: 'android.permission.READ_PHONE_NUMBERS',
  READ_PHONE_STATE: 'android.permission.READ_PHONE_STATE',
  READ_SMS: 'android.permission.READ_SMS',
  RECEIVE_MMS: 'android.permission.RECEIVE_MMS',
  RECEIVE_SMS: 'android.permission.RECEIVE_SMS',
  RECEIVE_WAP_PUSH: 'android.permission.RECEIVE_WAP_PUSH',
  RECORD_AUDIO: 'android.permission.RECORD_AUDIO',
  SEND_SMS: 'android.permission.SEND_SMS',
  USE_SIP: 'android.permission.USE_SIP',
  UWB_RANGING: 'android.permission.UWB_RANGING',
  WRITE_CALENDAR: 'android.permission.WRITE_CALENDAR',
  WRITE_CALL_LOG: 'android.permission.WRITE_CALL_LOG',
  WRITE_CONTACTS: 'android.permission.WRITE_CONTACTS',
  WRITE_EXTERNAL_STORAGE: 'android.permission.WRITE_EXTERNAL_STORAGE',
} as const);

export type AndroidPermissionMap = typeof ANDROID;

export const PERMISSIONS = Object.freeze({
  ANDROID,
  IOS: {} as IOSPermissionMap,
  WINDOWS: {} as WindowsPermissionMap,
} as const);
