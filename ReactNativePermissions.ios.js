'use strict';

var React = require('react-native');
var RNPermissions = React.NativeModules.ReactNativePermissions;


class ReactNativePermissions {
	canOpenSettings() {
		return RNPermissions.canOpenSettings()
	}

	openSettings() {
		return RNPermissions.openSettings()
	}

	getPermissionTypes() {
		return RNPermissions.PermissionTypes;
	}

	getPermissionStatus(permission) {
		if (RNPermissions.PermissionTypes.includes(permission)) {
			return RNPermissions.getPermissionStatus(permission)
		} else {
			return Promise.reject(`ReactNativePermissions: ${permission} is not a valid permission type`)
		}
	}

	requestPermission(permission, type) {
		switch (permission) {
			case "location":
				return RNPermissions.requestLocation(type)
			case "camera":
				return RNPermissions.requestCamera();
			case "microphone":
				return RNPermissions.requestMicrophone();
			case "photo":
				return RNPermissions.requestPhoto();
			case "contacts":
				return RNPermissions.requestContacts();
			case "event":
				return RNPermissions.requestEvent();
			case "reminder":
				return RNPermissions.requestReminder();
			case "bluetooth":
				return RNPermissions.requestBluetooth();
			case "notification":
				return RNPermissions.requestNotification(type)
			case "backgroundRefresh":
				return Promise.reject('You cannot request backgroundRefresh')
			default:
				return Promise.reject('invalid type: ' + type)
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
