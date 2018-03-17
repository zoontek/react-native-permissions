// @flow

import { Platform } from 'react-native'

import PermissionsAndroid from './lib/android'
import PermissionsIOS from './lib/ios'

const Permissions = Platform.OS === 'ios' ? PermissionsIOS : PermissionsAndroid

export default Permissions
