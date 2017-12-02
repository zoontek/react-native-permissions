// @flow

import { NativeModules } from 'react-native'
const PermissionsIOS = NativeModules.ReactNativePermissions

type Status = 'authorized' | 'denied' | 'restricted' | 'undetermined'
type Rationale = { title: string, message: string }
type Options = string | { type: string, rationale?: Rationale }

const permissionTypes = [
  'location',
  'camera',
  'microphone',
  'photo',
  'contacts',
  'event',
  'reminder',
  'bluetooth',
  'notification',
  'backgroundRefresh',
  'speechRecognition',
]

const DEFAULTS = {
  location: 'whenInUse',
  notification: ['alert', 'badge', 'sound'],
}

class ReactNativePermissions {
  canOpenSettings: () => Promise<boolean> = () =>
    PermissionsIOS.canOpenSettings()

  openSettings: () => Promise<*> = () => PermissionsIOS.openSettings()

  getTypes: () => Array<string> = () => permissionTypes

  check = (permission: string, type?: string): Promise<Status> => {
    if (!permissionTypes.includes(permission)) {
      const error = new Error(
        `ReactNativePermissions: ${
          permission
        } is not a valid permission type on iOS`,
      )

      return Promise.reject(error)
    }

    return PermissionsIOS.getPermissionStatus(
      permission,
      type || DEFAULTS[permission],
    )
  }

  request = (permission: string, options?: Options): Promise<Status> => {
    let type

    if (typeof options === 'string') {
      type = options
    } else if (options && options.type) {
      type = options.type
    }

    if (!permissionTypes.includes(permission)) {
      const error = new Error(
        `ReactNativePermissions: ${
          permission
        } is not a valid permission type on iOS`,
      )

      return Promise.reject(error)
    }

    if (permission == 'backgroundRefresh') {
      const error = new Error(
        'ReactNativePermissions: You cannot request backgroundRefresh',
      )

      return Promise.reject(error)
    }

    return PermissionsIOS.requestPermission(
      permission,
      type || DEFAULTS[permission],
    )
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

module.exports = new ReactNativePermissions()
