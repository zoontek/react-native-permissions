'use strict';

var React = require('react-native');
var RNPermissions = React.NativeModules.ReactNativePermissions;

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
]

class ReactNativePermissions {
	constructor() {
		//legacy support
		this.StatusUndetermined = 'undetermined'
		this.StatusDenied = 'denied'
		this.StatusAuthorized = 'authorized'
		this.StatusRestricted = 'restricted'

		RNPTypes.forEach(type => {
			let methodName = `${type}PermissionStatus`
			this[methodName] = p => {
				console.warn(`ReactNativePermissions: ${methodName} is depricated. Use getPermissionStatus('${type}') instead.`)
				return this.getPermissionStatus(p == 'reminder' ? p : type)
			}
		})
	}

	canOpenSettings() {
		return RNPermissions.canOpenSettings()
	}

	openSettings() {
		return RNPermissions.openSettings()
	}

	getPermissionTypes() {
		return RNPTypes;
	}

        getPermissionStatus(permission) {
               if (RNPTypes.indexOf(permission) >= 0) {
			return RNPermissions.getPermissionStatus(permission)
		} else {
			return Promise.reject(`ReactNativePermissions: ${permission} is not a valid permission type`)
		}
	}

	requestPermission(permission, type) {
		switch (permission) {
			case "location":
				return RNPermissions.requestLocation(type || 'always')
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
				return RNPermissions.requestNotification(type || ['alert', 'badge', 'sound'])
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

module.exports = new ReactNativePermissions()
