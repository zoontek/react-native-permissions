package com.zoontek.rnpermissions

import android.util.SparseArray

import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.modules.core.PermissionListener

@ReactModule(name = RNPermissionsModuleImpl.NAME)
class RNPermissionsModule(reactContext: ReactApplicationContext?) :
  ReactContextBaseJavaModule(reactContext), PermissionListener {

  private val callbacks = SparseArray<Callback>()

  override fun getName(): String {
    return RNPermissionsModuleImpl.NAME
  }

  @ReactMethod
  fun openSettings(promise: Promise) {
    RNPermissionsModuleImpl.openSettings(reactApplicationContext, promise)
  }

  @ReactMethod(isBlockingSynchronousMethod = true)
  fun check(permission: String): Boolean {
    return RNPermissionsModuleImpl.check(reactApplicationContext, permission)
  }

  @ReactMethod
  fun checkNotifications(promise: Promise) {
    RNPermissionsModuleImpl.checkNotifications(reactApplicationContext, promise)
  }

  @ReactMethod(isBlockingSynchronousMethod = true)
  fun checkMultiple(permissions: ReadableArray): WritableMap {
    return RNPermissionsModuleImpl.checkMultiple(reactApplicationContext, permissions)
  }

  @ReactMethod
  fun request(permission: String, promise: Promise) {
    RNPermissionsModuleImpl.request(reactApplicationContext, this, callbacks, permission, promise)
  }

  @ReactMethod
  fun requestNotifications(options: ReadableArray, promise: Promise) {
    RNPermissionsModuleImpl.requestNotifications(reactApplicationContext, promise)
  }

  @ReactMethod
  fun requestMultiple(permissions: ReadableArray, promise: Promise) {
    RNPermissionsModuleImpl.requestMultiple(reactApplicationContext, this, callbacks, permissions, promise)
  }

  @ReactMethod
  fun shouldShowRequestRationale(permission: String, promise: Promise) {
    RNPermissionsModuleImpl.shouldShowRequestRationale(reactApplicationContext, permission, promise)
  }

  @ReactMethod
  fun checkLocationAccuracy(promise: Promise) {
    RNPermissionsModuleImpl.checkLocationAccuracy(promise)
  }

  @ReactMethod
  fun requestLocationAccuracy(purposeKey: String, promise: Promise) {
    RNPermissionsModuleImpl.requestLocationAccuracy(promise)
  }

  @ReactMethod
  fun openPhotoPicker(promise: Promise) {
    RNPermissionsModuleImpl.openPhotoPicker(promise)
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
    return RNPermissionsModuleImpl.onRequestPermissionsResult(reactApplicationContext, callbacks, requestCode, grantResults)
  }
}
