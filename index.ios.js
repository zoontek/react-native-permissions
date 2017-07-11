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

	request(permission, options) {
		let type = null;
		if (typeof options === 'string' || options instanceof Array) {
			console.warn('[react-native-permissions] : You are using a deprecated version of request(). You should use an object as second parameter. Please check the documentation for more information : https://github.com/yonahforst/react-native-permissions');
			type = options;
		} else {
			type = options.type;
		}

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
