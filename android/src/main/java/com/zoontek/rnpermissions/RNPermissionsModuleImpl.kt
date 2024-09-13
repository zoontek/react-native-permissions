package com.zoontek.rnpermissions

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Settings
import android.util.SparseArray

import androidx.core.app.NotificationManagerCompat

import com.facebook.common.logging.FLog
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.Callback
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.modules.core.PermissionAwareActivity
import com.facebook.react.modules.core.PermissionListener

object RNPermissionsModuleImpl {
  const val NAME: String = "RNPermissions"

  private var requestCode = 0

  private const val ERROR_INVALID_ACTIVITY = "E_INVALID_ACTIVITY"
  private const val GRANTED = "granted"
  private const val DENIED = "denied"
  private const val BLOCKED = "blocked"

  fun openSettings(reactContext: ReactApplicationContext, promise: Promise) {
    try {
      val intent = Intent().apply {
        setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        setData(Uri.fromParts("package", reactContext.packageName, null))
      }

      reactContext.startActivity(intent)
      promise.resolve(true)
    } catch (e: Exception) {
      promise.reject(ERROR_INVALID_ACTIVITY, e)
    }
  }

  fun check(reactContext: ReactApplicationContext, permission: String, promise: Promise) {
    val context = reactContext.baseContext
    promise.resolve(context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED)
  }

  // Only used on Android < 13 (the POST_NOTIFICATIONS runtime permission isn't available)
  fun checkNotifications(reactContext: ReactApplicationContext, promise: Promise) {
    val granted = NotificationManagerCompat.from(reactContext).areNotificationsEnabled()

    val output = Arguments.createMap().apply {
      putBoolean("granted", granted)
      putMap("settings", Arguments.createMap())
    }

    promise.resolve(output)
  }

  fun checkMultiple(reactContext: ReactApplicationContext, permissions: ReadableArray, promise: Promise) {
    val output: WritableMap = WritableNativeMap()
    val context = reactContext.baseContext

    for (i in 0 until permissions.size()) {
      val permission = permissions.getString(i)

      output.putBoolean(
        permission,
        context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED
      )
    }

    promise.resolve(output)
  }

  fun request(
    reactContext: ReactApplicationContext,
    listener: PermissionListener,
    callbacks: SparseArray<Callback>,
    permission: String,
    promise: Promise
  ) {
    val context = reactContext.baseContext

    if (context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
      return promise.resolve(GRANTED)
    }

    try {
      val activity = getPermissionAwareActivity(reactContext)

      callbacks.put(
        requestCode,
        Callback { args ->
          val results = args[0] as IntArray
          val callbackActivity = args[1] as PermissionAwareActivity

          val status = when {
            results.isNotEmpty() && results[0] == PackageManager.PERMISSION_GRANTED -> GRANTED
            callbackActivity.shouldShowRequestPermissionRationale(permission) -> DENIED
            else -> BLOCKED
          }

          promise.resolve(status)
        })

      activity.requestPermissions(arrayOf(permission), requestCode, listener)
      requestCode++
    } catch (e: IllegalStateException) {
      promise.reject(ERROR_INVALID_ACTIVITY, e)
    }
  }

  // Only used on Android < 13 (the POST_NOTIFICATIONS runtime permission isn't available)
  fun requestNotifications(reactContext: ReactApplicationContext, promise: Promise) {
    val granted = NotificationManagerCompat.from(reactContext).areNotificationsEnabled()

    val output = Arguments.createMap().apply {
      putString("status", if (granted) GRANTED else BLOCKED)
      putMap("settings", Arguments.createMap())
    }

    promise.resolve(output)
  }

  fun requestMultiple(
    reactContext: ReactApplicationContext,
    listener: PermissionListener,
    callbacks: SparseArray<Callback>,
    permissions: ReadableArray,
    promise: Promise
  ) {
    val grantedPermissions: WritableMap = WritableNativeMap()
    val permissionsToCheck = ArrayList<String>()
    var checkedPermissionsCount = 0
    val context = reactContext.baseContext

    for (i in 0 until permissions.size()) {
      val permission = permissions.getString(i)

      if (context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
        grantedPermissions.putString(permission, GRANTED)
        checkedPermissionsCount++
      } else {
        permissionsToCheck.add(permission)
      }
    }

    if (permissions.size() == checkedPermissionsCount) {
      return promise.resolve(grantedPermissions)
    }

    try {
      val activity = getPermissionAwareActivity(reactContext)

      callbacks.put(
        requestCode,
        Callback { args ->
          val results = args[0] as IntArray
          val callbackActivity = args[1] as PermissionAwareActivity

          permissionsToCheck.forEachIndexed { index, permission ->
            val status = when {
              results.isNotEmpty() && results[index] == PackageManager.PERMISSION_GRANTED -> GRANTED
              callbackActivity.shouldShowRequestPermissionRationale(permission) -> DENIED
              else -> BLOCKED
            }

            grantedPermissions.putString(permission, status)
          }

          promise.resolve(grantedPermissions)
        })

      activity.requestPermissions(permissionsToCheck.toTypedArray<String>(), requestCode, listener)
      requestCode++
    } catch (e: IllegalStateException) {
      promise.reject(ERROR_INVALID_ACTIVITY, e)
    }
  }

  fun shouldShowRequestRationale(reactContext: ReactApplicationContext, permission: String, promise: Promise) {
    try {
      promise.resolve(getPermissionAwareActivity(reactContext).shouldShowRequestPermissionRationale(permission))
    } catch (e: IllegalStateException) {
      promise.reject(ERROR_INVALID_ACTIVITY, e)
    }
  }

  private fun getPermissionAwareActivity(reactContext: ReactApplicationContext): PermissionAwareActivity {
    val activity = reactContext.currentActivity

    checkNotNull(activity) {
      "Tried to use permissions API while not attached to an Activity."
    }
    check(activity is PermissionAwareActivity) {
      "Tried to use permissions API but the host Activity doesn't implement PermissionAwareActivity."
    }

    return activity
  }

  fun openPhotoPicker(promise: Promise) {
    promise.reject("Permissions:openPhotoPicker", "openPhotoPicker is not supported on Android")
  }

  fun checkLocationAccuracy(promise: Promise) {
    promise.reject("Permissions:checkLocationAccuracy", "checkLocationAccuracy is not supported on Android")
  }

  fun requestLocationAccuracy(promise: Promise) {
    promise.reject("Permissions:requestLocationAccuracy", "requestLocationAccuracy is not supported on Android")
  }

  fun onRequestPermissionsResult(
    reactContext: ReactApplicationContext,
    callbacks: SparseArray<Callback>,
    requestCode: Int,
    grantResults: IntArray
  ): Boolean {
    try {
      val callback = callbacks[requestCode]

      if (callback != null) {
        callback.invoke(grantResults, getPermissionAwareActivity(reactContext))
        callbacks.remove(requestCode)
      } else {
        FLog.w("PermissionsModule", "Unable to find callback with requestCode %d", requestCode)
      }

      return callbacks.size() == 0
    } catch (e: IllegalStateException) {
      FLog.e("PermissionsModule", e, "Unexpected invocation of `onRequestPermissionsResult`")
      return false
    }
  }
}
