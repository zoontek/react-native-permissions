// @flow

import { NativeModules } from 'react-native'
const PermissionsIOS = NativeModules.ReactNativePermissions

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
  canOpenSettings = () => PermissionsIOS.canOpenSettings()
  openSettings = () => PermissionsIOS.openSettings()
  getTypes = () => permissionTypes

  check = (permission, type) => {
    if (!permissionTypes.includes(permission)) {
      return Promise.reject(
        `ReactNativePermissions: ${
          permission
        } is not a valid permission type on iOS`,
      )
    }

    return PermissionsIOS.getPermissionStatus(permission, type)
  }

  request = (permission, type) => {
    if (!permissionTypes.includes(permission)) {
      return Promise.reject(
        `ReactNativePermissions: ${
          permission
        } is not a valid permission type on iOS`,
      )
    }

    if (permission == 'backgroundRefresh') {
      return Promise.reject(
        'ReactNativePermissions: You cannot request backgroundRefresh',
      )
    }

    return PermissionsIOS.requestPermission(
      permission,
      type || DEFAULTS[permission],
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

export default new ReactNativePermissions()
