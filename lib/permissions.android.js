// @flow

import { AsyncStorage, NativeModules, PermissionsAndroid } from 'react-native'

type Status = 'authorized' | 'denied' | 'restricted' | 'undetermined'
type Rationale = { title: string, message: string }
type CheckOptions = string | { type: string }
type RequestOptions = string | { type: string, rationale?: Rationale }

const permissionTypes = {
  location: PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION,
  camera: PermissionsAndroid.PERMISSIONS.CAMERA,
  microphone: PermissionsAndroid.PERMISSIONS.RECORD_AUDIO,
  contacts: PermissionsAndroid.PERMISSIONS.READ_CONTACTS,
  event: PermissionsAndroid.PERMISSIONS.READ_CALENDAR,
  storage: PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE,
  photo: PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE,
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

const setDidAskOnce = (permission: string) =>
  AsyncStorage.setItem(STORAGE_KEY + permission, 'true')

const getDidAskOnce = (permission: string) =>
  AsyncStorage.getItem(STORAGE_KEY + permission).then(item => !!item)

class ReactNativePermissions {
  canOpenSettings: () => Promise<boolean> = () => Promise.resolve(false)

  openSettings: () => Promise<*> = () =>
    Promise.reject(new Error("'openSettings' is deprecated on android"))

  getTypes: () => Array<string> = () => Object.keys(permissionTypes)

  check = (permission: string, options?: CheckOptions): Promise<Status> => {
    if (!permissionTypes[permission]) {
      const error = new Error(
        `ReactNativePermissions: ${
          permission
        } is not a valid permission type on Android`,
      )

      return Promise.reject(error)
    }

    return PermissionsAndroid.check(permissionTypes[permission]).then(
      isAuthorized => {
        if (isAuthorized) {
          return 'authorized'
        }

        return getDidAskOnce(permission).then(didAsk => {
          if (didAsk) {
            return NativeModules.PermissionsAndroid.shouldShowRequestPermissionRationale(
              permissionTypes[permission],
            ).then(shouldShow => (shouldShow ? 'denied' : 'restricted'))
          }

          return 'undetermined'
        })
      },
    )
  }

  request = (permission: string, options?: RequestOptions): Promise<Status> => {
    if (!permissionTypes[permission]) {
      const error = new Error(
        `ReactNativePermissions: ${
          permission
        } is not a valid permission type on Android`,
      )

      return Promise.reject(error)
    }

    let rationale

    if (options && options.rationale) {
      rationale = options.rationale
    }

    return PermissionsAndroid.request(
      permissionTypes[permission],
      rationale,
    ).then(result => {
      // PermissionsAndroid.request() to native module resolves to boolean
      // rather than string if running on OS version prior to Android M
      if (typeof result === 'boolean') {
        return result ? 'authorized' : 'denied'
      }

      return setDidAskOnce(permission).then(() => RESULTS[result])
    })
  }

  checkMultiple = (permissions: Array<string>): Promise<{ [string]: string }> =>
    Promise.all(permissions.map(permission => this.check(permission))).then(
      result =>
        result.reduce((acc, value, index) => {
          const name = permissions[index]
          acc[name] = value
          return acc
        }, {}),
    )
}

export default new ReactNativePermissions()
