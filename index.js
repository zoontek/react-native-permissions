// @flow

import {NativeModules, PermissionsAndroid, Platform} from 'react-native';
import AsyncStorage from '@react-native-community/async-storage';
const NativeModule = NativeModules.ReactNativePermissions;

export type PermissionStatus =
  | 'authorized'
  | 'denied'
  | 'restricted'
  | 'undetermined';

export type Rationale = {
  title: string,
  message: string,
  buttonPositive?: string,
  buttonNegative?: string,
  buttonNeutral?: string,
};

const ASYNC_STORAGE_KEY = '@RNPermissions:didAskPermission:';

const PERMISSIONS = Platform.select({
  ios: {
    backgroundRefresh: 'backgroundRefresh',
    bluetooth: 'bluetooth',
    camera: 'camera',
    contacts: 'contacts',
    event: 'event',
    location: 'location',
    mediaLibrary: 'mediaLibrary',
    microphone: 'microphone',
    motion: 'motion',
    notification: 'notification',
    photo: 'photo',
    reminder: 'reminder',
    speechRecognition: 'speechRecognition',
  },
  android: {
    callPhone: PermissionsAndroid.PERMISSIONS.CALL_PHONE,
    camera: PermissionsAndroid.PERMISSIONS.CAMERA,
    coarseLocation: PermissionsAndroid.PERMISSIONS.ACCESS_COARSE_LOCATION,
    contacts: PermissionsAndroid.PERMISSIONS.READ_CONTACTS,
    event: PermissionsAndroid.PERMISSIONS.READ_CALENDAR,
    location: PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
    microphone: PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
    photo: PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE,
    readSms: PermissionsAndroid.PERMISSIONS.READ_SMS,
    receiveSms: PermissionsAndroid.PERMISSIONS.RECEIVE_SMS,
    sendSms: PermissionsAndroid.PERMISSIONS.SEND_SMS,
    storage: PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE,
  },
});

const IOS_DEFAULT_OPTIONS = {
  location: 'whenInUse',
  notification: ['alert', 'badge', 'sound'],
};

const ANDROID_RESULTS = {
  granted: 'authorized',
  denied: 'denied',
  never_ask_again: 'restricted',
};

const setDidAskOnce = (permission: string) =>
  AsyncStorage.setItem(ASYNC_STORAGE_KEY + permission, 'true');

const getDidAskOnce = (permission: string) =>
  AsyncStorage.getItem(ASYNC_STORAGE_KEY + permission).then(item => !!item);

class ReactNativePermissions {
  canOpenSettings(): Promise<boolean> {
    return Platform.OS === 'ios'
      ? NativeModule.canOpenSettings().then(result => !!result)
      : Promise.resolve(false);
  }

  openSettings(): Promise<void> {
    return Platform.OS === 'ios'
      ? NativeModule.openSettings()
      : Promise.reject(new Error("'openSettings' is deprecated on android"));
  }

  getTypes(): string[] {
    return Object.keys(PERMISSIONS);
  }

  check = (
    permission: string,
    options?: string | {type?: string},
  ): Promise<PermissionStatus> => {
    if (!PERMISSIONS[permission]) {
      return Promise.reject(
        new Error(
          `ReactNativePermissions: ${permission} is not a valid permission type`,
        ),
      );
    }

    if (Platform.OS === 'ios') {
      let type = IOS_DEFAULT_OPTIONS[permission];

      if (typeof options === 'string') {
        type = options;
      } else if (options && options.type) {
        type = options.type;
      }

      return NativeModule.getPermissionStatus(permission, type);
    }

    if (Platform.OS === 'android') {
      return PermissionsAndroid.check(PERMISSIONS[permission]).then(granted => {
        if (granted) {
          return 'authorized';
        }

        return getDidAskOnce(permission).then(didAsk => {
          if (didAsk) {
            return NativeModules.PermissionsAndroid.shouldShowRequestPermissionRationale(
              PERMISSIONS[permission],
            ).then(shouldShow => (shouldShow ? 'denied' : 'restricted'));
          }

          return 'undetermined';
        });
      });
    }

    return Promise.resolve('restricted');
  };

  request = (
    permission: string,
    options?: string | {type?: string, rationale?: Rationale},
  ): Promise<PermissionStatus> => {
    if (!PERMISSIONS[permission]) {
      return Promise.reject(
        new Error(
          `ReactNativePermissions: ${permission} is not a valid permission type`,
        ),
      );
    }

    if (Platform.OS === 'ios') {
      if (permission == 'backgroundRefresh') {
        return Promise.reject(
          new Error(
            'ReactNativePermissions: You cannot request backgroundRefresh',
          ),
        );
      }

      let type = IOS_DEFAULT_OPTIONS[permission];

      if (typeof options === 'string') {
        type = options;
      } else if (options && options.type) {
        type = options.type;
      }

      return NativeModule.requestPermission(permission, type);
    }

    if (Platform.OS === 'android') {
      let rationale: Rationale;

      if (typeof options === 'object' && options.rationale) {
        rationale = options.rationale;
      }

      return PermissionsAndroid.request(
        PERMISSIONS[permission],
        rationale,
      ).then(result => {
        // PermissionsAndroid.request() to native module resolves to boolean
        // rather than string if running on OS version prior to Android M
        if (typeof result === 'boolean') {
          return result ? 'authorized' : 'denied';
        }

        return setDidAskOnce(permission).then(() => ANDROID_RESULTS[result]);
      });
    }

    return Promise.resolve('restricted');
  };

  checkMultiple = (
    permissions: string[],
  ): Promise<{[permission: string]: PermissionStatus}> => {
    return Promise.all(
      permissions.map(permission => this.check(permission)),
    ).then(result =>
      result.reduce((acc, value, i) => {
        acc[permissions[i]] = value;
        return acc;
      }, {}),
    );
  };
}

export default new ReactNativePermissions();
