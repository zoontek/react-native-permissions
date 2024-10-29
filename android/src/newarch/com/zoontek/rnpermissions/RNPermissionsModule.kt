package com.zoontek.rnpermissions

import android.util.SparseArray

import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.modules.core.PermissionListener

@ReactModule(name = RNPermissionsModuleImpl.NAME)
class RNPermissionsModule(reactContext: ReactApplicationContext?) :
  NativeRNPermissionsSpec(reactContext), PermissionListener {

  private val callbacks = SparseArray<Callback>()

  override fun getName(): String {
    return RNPermissionsModuleImpl.NAME
  }

  override fun openSettings(type: String?, promise: Promise) {
    RNPermissionsModuleImpl.openSettings(reactApplicationContext, type, promise)
  }

  override fun canScheduleExactAlarms(promise: Promise) {
    RNPermissionsModuleImpl.canScheduleExactAlarms(reactApplicationContext, promise)
  }

  override fun check(permission: String, promise: Promise) {
    RNPermissionsModuleImpl.check(reactApplicationContext, permission, promise)
  }

  override fun checkNotifications(promise: Promise) {
    RNPermissionsModuleImpl.checkNotifications(reactApplicationContext, promise)
  }

  override fun checkMultiple(permissions: ReadableArray, promise: Promise) {
    RNPermissionsModuleImpl.checkMultiple(reactApplicationContext, permissions, promise)
  }

  override fun request(permission: String, promise: Promise) {
    RNPermissionsModuleImpl.request(reactApplicationContext, this, callbacks, permission, promise)
  }

  override fun requestNotifications(options: ReadableArray, promise: Promise) {
    RNPermissionsModuleImpl.requestNotifications(reactApplicationContext, promise)
  }

  override fun requestMultiple(permissions: ReadableArray, promise: Promise) {
    RNPermissionsModuleImpl.requestMultiple(reactApplicationContext, this, callbacks, permissions, promise)
  }

  override fun shouldShowRequestRationale(permission: String, promise: Promise) {
    RNPermissionsModuleImpl.shouldShowRequestRationale(reactApplicationContext, permission, promise)
  }

  override fun checkLocationAccuracy(promise: Promise) {
    RNPermissionsModuleImpl.checkLocationAccuracy(promise)
  }

  override fun requestLocationAccuracy(purposeKey: String, promise: Promise) {
    RNPermissionsModuleImpl.requestLocationAccuracy(promise)
  }

  override fun openPhotoPicker(promise: Promise) {
    RNPermissionsModuleImpl.openPhotoPicker(promise)
  }

  override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>, grantResults: IntArray): Boolean {
    return RNPermissionsModuleImpl.onRequestPermissionsResult(reactApplicationContext, callbacks, requestCode, grantResults)
  }
}
