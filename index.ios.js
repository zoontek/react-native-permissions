'use strict';

const ReactNative = require('react-native');
const RNPermissions = ReactNative.NativeModules.ReactNativePermissions;

const RNPTypes = [
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
	'location' : 'whenInUse',
	'notification': ['alert', 'badge', 'sound'],
}

class ReactNativePermissions {
	canOpenSettings() {
		return RNPermissions.canOpenSettings()
	}

	openSettings() {
		return RNPermissions.openSettings()
	}

	getTypes() {
		return RNPTypes;
	}

	check(permission, type) {
  	if (!RNPTypes.includes(permission)) {
			return Promise.reject(`ReactNativePermissions: ${permission} is not a valid permission type on iOS`);
		}
		
		return RNPermissions.getPermissionStatus(permission, type);
	}

	request(permission, type) {
		if (!RNPTypes.includes(permission)) {
			return Promise.reject(`ReactNativePermissions: ${permission} is not a valid permission type on iOS`);
		}

		if (permission == 'backgroundRefresh') {
			return Promise.reject('ReactNativePermissions: You cannot request backgroundRefresh')
		}

		type = type || DEFAULTS[permission]

		return RNPermissions.requestPermission(permission, type)
	}

	checkMultiple(permissions) {
		return Promise.all(permissions.map(this.check.bind(this)))
			.then(res => res.reduce((pre, cur, i) => {
				var name = permissions[i]
				pre[name] = cur
				return pre
			}, {}))
	}
}

module.exports = new ReactNativePermissions()
