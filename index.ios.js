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

    return PermissionsIOS.getPermissionStatus(
      permission,
      type || DEFAULTS[permission],
    )
  }

  request = (permission, options) => {
    let type = null;
    if (typeof options === 'string' || options instanceof Array) {
      console.warn('[react-native-permissions] : You are using a deprecated version of request(). You should use an object as second parameter. Please check the documentation for more information : https://github.com/yonahforst/react-native-permissions');
      type = options;
    } else if (options != null) {
      type = options.type;
    }

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
