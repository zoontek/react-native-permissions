package com.zoontek.rnpermissions

import android.app.AlarmManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
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
  const val NAME = "RNPermissions"

  private var requestCode = 0

  private const val ERROR_INVALID_ACTIVITY = "E_INVALID_ACTIVITY"
  private const val GRANTED = "granted"
  private const val DENIED = "denied"
  private const val UNAVAILABLE = "unavailable"
  private const val BLOCKED = "blocked"

  // Based on https://developer.android.com/reference/android/Manifest.permission
  // Permissions not explicitly listed are considered available (API < 21)
  private val minimumApi = mapOf(
    "android.permission.ACCEPT_HANDOVER" to 28,
    "android.permission.ACCESS_BACKGROUND_LOCATION" to 29,
    "android.permission.ACCESS_MEDIA_LOCATION" to 29,
    "android.permission.ACTIVITY_RECOGNITION" to 29,
    "android.permission.ANSWER_PHONE_CALLS" to 26,
    "android.permission.BLUETOOTH_ADVERTISE" to 31,
    "android.permission.BLUETOOTH_CONNECT" to 31,
    "android.permission.BLUETOOTH_SCAN" to 31,
    "android.permission.BODY_SENSORS_BACKGROUND" to 33,
    "android.permission.NEARBY_WIFI_DEVICES" to 33,
    "android.permission.READ_MEDIA_AUDIO" to 33,
    "android.permission.READ_MEDIA_IMAGES" to 33,
    "android.permission.READ_MEDIA_VIDEO" to 33,
    "android.permission.READ_MEDIA_VISUAL_USER_SELECTED" to 34,
    "android.permission.READ_PHONE_NUMBERS" to 26,
    "android.permission.UWB_RANGING" to 31
  )

  private fun isPermissionAvailable(permission: String): Boolean =
    Build.VERSION.SDK_INT >= (minimumApi[permission] ?: Build.VERSION_CODES.BASE)

  fun openSettings(reactContext: ReactApplicationContext, type: String?, promise: Promise) {
    try {
      val packageName = reactContext.packageName

      val intent = when {
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && type == "alarms" -> Intent().apply {
          setAction(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
          setData(Uri.parse("package:${packageName}"))
        }
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && type == "notifications" -> Intent().apply {
          setAction(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
          putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
        }
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE && type == "fullscreen" -> Intent().apply {
          setAction(Settings.ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT)
          setData(Uri.parse("package:${packageName}"))
        }
        else -> Intent().apply {
          setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
          setData(Uri.parse("package:${packageName}"))
        }
      }.apply {
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
      }

      reactContext.startActivity(intent)
      promise.resolve(true)
    } catch (e: Exception) {
      promise.reject(ERROR_INVALID_ACTIVITY, e)
    }
  }

  fun canScheduleExactAlarms(reactContext: ReactApplicationContext, promise: Promise) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
      return promise.resolve(true)
    }

    val alarmManager = reactContext.getSystemService(Context.ALARM_SERVICE) as? AlarmManager
    val canScheduleExactAlarms: Boolean = alarmManager?.canScheduleExactAlarms() ?: false

    promise.resolve(canScheduleExactAlarms)
  }

  fun canUseFullScreenIntent(reactContext: ReactApplicationContext, promise: Promise) {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
      return promise.resolve(true)
    }

    val notificationManager = reactContext.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    val canUseFullScreenIntent = notificationManager.canUseFullScreenIntent()

    promise.resolve(canUseFullScreenIntent)
  }

  fun check(reactContext: ReactApplicationContext, permission: String, promise: Promise) {
    if (!isPermissionAvailable(permission)) {
      return promise.resolve(UNAVAILABLE)
    }

    val context = reactContext.baseContext

    if (context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
      promise.resolve(GRANTED)
    } else {
      promise.resolve(DENIED)
    }
  }

  // Only used on Android < 13 (the POST_NOTIFICATIONS runtime permission isn't available)
  fun checkNotifications(reactContext: ReactApplicationContext, promise: Promise) {
    val enabled = NotificationManagerCompat.from(reactContext).areNotificationsEnabled()

    val output = Arguments.createMap().apply {
      putString("status", if (enabled) GRANTED else DENIED)
      putMap("settings", Arguments.createMap())
    }

    promise.resolve(output)
  }

  fun checkMultiple(reactContext: ReactApplicationContext, permissions: ReadableArray, promise: Promise) {
    val output: WritableMap = WritableNativeMap()
    val context = reactContext.baseContext

    for (i in 0 until permissions.size()) {
      val permission = permissions.getString(i)

      if (permission.isNullOrBlank()) {
        continue;
      }

      output.putString(
        permission,
        when {
          !isPermissionAvailable(permission) -> UNAVAILABLE
          context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED -> GRANTED
          else -> DENIED
        }
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
    if (!isPermissionAvailable(permission)) {
      return promise.resolve(UNAVAILABLE)
    }

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

          promise.resolve(
            when {
              results.getOrNull(0) == PackageManager.PERMISSION_GRANTED -> GRANTED
              callbackActivity.shouldShowRequestPermissionRationale(permission) -> DENIED
              else -> BLOCKED
            }
          )
        })

      activity.requestPermissions(arrayOf(permission), requestCode, listener)
      requestCode++
    } catch (e: IllegalStateException) {
      promise.reject(ERROR_INVALID_ACTIVITY, e)
    }
  }

  // Only used on Android < 13 (the POST_NOTIFICATIONS runtime permission isn't available)
  fun requestNotifications(reactContext: ReactApplicationContext, promise: Promise) {
    val enabled = NotificationManagerCompat.from(reactContext).areNotificationsEnabled()

    val output = Arguments.createMap().apply {
      putString("status", if (enabled) GRANTED else BLOCKED)
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
    val output: WritableMap = WritableNativeMap()
    val permissionsToCheck = ArrayList<String>()
    var checkedPermissionsCount = 0
    val context = reactContext.baseContext

    for (i in 0 until permissions.size()) {
      val permission = permissions.getString(i)

      if (permission.isNullOrBlank()) {
        continue;
      }

      if (!isPermissionAvailable(permission)) {
        output.putString(permission, UNAVAILABLE)
        checkedPermissionsCount++
      } else if (context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
        output.putString(permission, GRANTED)
        checkedPermissionsCount++
      } else {
        permissionsToCheck.add(permission)
      }
    }

    if (permissions.size() == checkedPermissionsCount) {
      return promise.resolve(output)
    }

    try {
      val activity = getPermissionAwareActivity(reactContext)

      callbacks.put(
        requestCode,
        Callback { args ->
          val results = args[0] as IntArray
          val callbackActivity = args[1] as PermissionAwareActivity

          permissionsToCheck.forEachIndexed { index, permission ->
            output.putString(
              permission,
              when {
                results.getOrNull(index) == PackageManager.PERMISSION_GRANTED -> GRANTED
                callbackActivity.shouldShowRequestPermissionRationale(permission) -> DENIED
                else -> BLOCKED
              }
            )

          }

          promise.resolve(output)
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
