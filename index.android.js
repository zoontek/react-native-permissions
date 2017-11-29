// @flow

import { AsyncStorage, NativeModules, PermissionsAndroid } from 'react-native'

const permissionTypes = {
  location: PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
  camera: PermissionsAndroid.PERMISSIONS.CAMERA,
  microphone: PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
  contacts: PermissionsAndroid.PERMISSIONS.READ_CONTACTS,
  event: PermissionsAndroid.PERMISSIONS.READ_CALENDAR,
  storage: PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE,
  photo: PermissionsAndroid.PERMISSIONS.READ_EXTERNAL_STORAGE,
  callPhone: PermissionsAndroid.PERMISSIONS.CALL_PHONE,
  readSms: PermissionsAndroid.PERMISSIONS.READ_SMS,
  receiveSms: PermissionsAndroid.PERMISSIONS.RECEIVE_SMS,
}

const RESULTS = {
  [PermissionsAndroid.RESULTS.GRANTED]: 'authorized',
  [PermissionsAndroid.RESULTS.DENIED]: 'denied',
  [PermissionsAndroid.RESULTS.NEVER_ASK_AGAIN]: 'restricted',
}

const STORAGE_KEY = '@RNPermissions:didAskPermission:'

const setDidAskOnce = permission =>
  AsyncStorage.setItem(STORAGE_KEY + permission, 'true')

const getDidAskOnce = permission =>
  AsyncStorage.getItem(STORAGE_KEY + permission).then(item => !!item)

class ReactNativePermissions {
  canOpenSettings = () => false
  openSettings = () => Promise.reject("'openSettings' is deprecated on android")
  getTypes = () => Object.keys(permissionTypes)

  check = permission => {
    const androidPermission = permissionTypes[permission]

    if (!androidPermission) {
      return Promise.reject(
        `ReactNativePermissions: ${
          permission
        } is not a valid permission type on Android`,
      )
    }

    return PermissionsAndroid.check(androidPermission).then(isAuthorized => {
      if (isAuthorized) {
        return 'authorized'
      }

      return getDidAskOnce(permission).then(didAsk => {
        if (didAsk) {
          return NativeModules.PermissionsAndroid.shouldShowRequestPermissionRationale(
            androidPermission,
          ).then(shouldShow => (shouldShow ? 'denied' : 'restricted'))
        }
        return 'undetermined'
      })
    })
  }

  request = (permission, { rationale }) => {
    const androidPermission = permissionTypes[permission]

    if (!androidPermission) {
      return Promise.reject(
        `ReactNativePermissions: ${
          permission
        } is not a valid permission type on Android`,
      )
    }

    return PermissionsAndroid.request(androidPermission, rationale).then(
      result => {
        // PermissionsAndroid.request() to native module resolves to boolean
        // rather than string if running on OS version prior to Android M
        if (typeof result === 'boolean') {
          return result ? 'authorized' : 'denied'
        }

        return setDidAskOnce(permission).then(() => RESULTS[result])
      },
    )
  }

  checkMultiple = permissions =>
    Promise.all(permissions.map(this.check)).then(result =>
      result.reduce((acc, value, index) => {
        const name = permissions[index]
        acc[name] = value
        return acc
      }, {}),
    )
}

module.exports = new ReactNativePermissions()
