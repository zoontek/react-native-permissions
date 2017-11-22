// @flow

import { Platform } from 'react-native'

export default (Platform.OS === 'ios'
  ? require('./index.ios')
  : require('./index.android'))
