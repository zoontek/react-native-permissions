'use strict';

var ReactNative = require('react-native')
var Platform = ReactNative.Platform
var RNPermissions = ReactNative.NativeModules.ReactNativePermissions;

const RNPTypes = {
	ios: [
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
	],
	android: [
		'location',
		'camera',
		'microphone',
		'contacts',
		'event',
		'photo',
		'storage',
		'notification',
	]
}

class ReactNativePermissions {
	constructor() {
		//legacy support
		this.StatusUndetermined = 'undetermined'
		this.StatusDenied = 'denied'
		this.StatusAuthorized = 'authorized'
		this.StatusRestricted = 'restricted'

		this.getPermissionTypes().forEach(type => {
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
		return RNPTypes[Platform.OS];
	}


	getPermissionStatus(permission, type) {
  	if (this.getPermissionTypes().indexOf(permission) >= 0) {
			return RNPermissions.getPermissionStatus(permission, type)
		} else {
			return Promise.reject(`ReactNativePermissions: ${permission} is not a valid permission type on ${Platform.OS}`)
		}
	}

	requestPermission(permission, type) {
		let options;

		if (this.getPermissionTypes().indexOf(permission) === -1) {
			return Promise.reject(`ReactNativePermissions: ${permission} is not a valid permission type on ${Platform.OS}`)
		} else if (permission == 'backgroundRefresh'){
			return Promise.reject('ReactNativePermissions: You cannot request backgroundRefresh')
		} else if (permission == 'location') {
			options = type || 'whenInUse'
		} else if (permission == 'notification') {
			if (Platform.OS === 'android') {
				return Promise.reject(`ReactNativePermissions: notification cannot be requested on Android`)
			}
			options = type || ['alert', 'badge', 'sound']
		}

		return RNPermissions.requestPermission(permission, options)
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
				return Promise.resolve(obj)
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
