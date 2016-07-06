'use strict';

var React = require('react-native');
var RNPermissions = React.NativeModules.ReactNativePermissions;

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
]

const permissionStatus = [
	'undetermined',
	'denied',
	'authorized',
	'restricted'
]

class ReactNativePermissions {
	canOpenSettings() {
		return RNPermissions.canOpenSettings()
	}

	openSettings() {
		return RNPermissions.openSettings()
	}

	getPermissionStatus(permission) {
		if (permissionTypes.includes(permission)) {
			return RNPermissions.getPermissionStatus(permission)
		} else {
			return Promise.reject(`ReactNativePermissions: ${permission} is not a valid permission type`)
		}
	}

	//recursive funciton to chain a promises for a list of permissions
	checkMultiplePermissions(permissions) {
		let i = permissions.length
		let that = this
		const obj = {}
		function processNext() {
			i--
			let p = permissions[i]
			
			if (!p) {
				return obj
			}

			return that.getPermissionStatus(p)
				.then(res => {
					obj[p] = res
					return processNext()
				}).catch(e => {
					console.warn(e)
					return processNext()
				})
		}
		return processNext()
	}
}

export default new ReactNativePermissions();
