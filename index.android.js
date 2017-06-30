'use strict';

const ReactNative = require('react-native')
const RNPermissions = ReactNative.PermissionsAndroid;
const AsyncStorage = ReactNative.AsyncStorage

const RNPTypes = {
	location: RNPermissions.PERMISSIONS.ACCESS_FINE_LOCATION,
	camera: RNPermissions.PERMISSIONS.CAMERA,
	microphone: RNPermissions.PERMISSIONS.RECORD_AUDIO,
	contacts: RNPermissions.PERMISSIONS.READ_CONTACTS,
	event: RNPermissions.PERMISSIONS.READ_CALENDAR,
	storage: RNPermissions.PERMISSIONS.READ_EXTERNAL_STORAGE,
	photo: RNPermissions.PERMISSIONS.READ_EXTERNAL_STORAGE,
}

const RESULTS = {
	[ RNPermissions.RESULTS.GRANTED ]: 'authorized',
	[ RNPermissions.RESULTS.DENIED ]: 'denied',
	[ RNPermissions.RESULTS.NEVER_ASK_AGAIN ]: 'restricted',
}

const STORAGE_KEY = '@RNPermissions:didAskPermission:'

const setDidAskOnce = p => AsyncStorage.setItem(STORAGE_KEY + p, 'true')
const getDidAskOnce = p =>  AsyncStorage.getItem(STORAGE_KEY + p).then(res => !!res)

class ReactNativePermissions {
	canOpenSettings() {
		return false
	}

	openSettings() {
		return Promise.reject('\'openSettings\' is Depricated on android')
	}

	getTypes() {
		return Object.keys(RNPTypes);
	}

	check(permission) {
		const androidPermission = RNPTypes[permission]
  	if (!androidPermission) return Promise.reject(`ReactNativePermissions: ${permission} is not a valid permission type on Android`);
		
		const shouldShowRationale = ReactNative.NativeModules.PermissionsAndroid.shouldShowRequestPermissionRationale;

		return RNPermissions.check(androidPermission)
			.then(isAuthorized => {
				if (isAuthorized) return 'authorized'

				return getDidAskOnce(permission)
					.then(didAsk => {
						if (didAsk) {
							return shouldShowRationale(androidPermission)
								.then(shouldShow => shouldShow ? 'denied' : 'restricted')
						}
						return 'undetermined'
					})
			})
	}


	request(permission) {
		const androidPermission = RNPTypes[permission]
  	if (!androidPermission) return Promise.reject(`ReactNativePermissions: ${permission} is not a valid permission type on Android`);


		return RNPermissions.request(androidPermission)
			.then(res => {
				return setDidAskOnce(permission)
					.then(() => RESULTS[res])
			});
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
