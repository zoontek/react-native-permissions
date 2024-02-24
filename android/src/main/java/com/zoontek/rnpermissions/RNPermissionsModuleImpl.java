package com.zoontek.rnpermissions;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Process;
import android.provider.Settings;
import android.util.SparseArray;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationManagerCompat;

import com.facebook.common.logging.FLog;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class RNPermissionsModuleImpl {

  private static final String ERROR_INVALID_ACTIVITY = "E_INVALID_ACTIVITY";
  public static final String NAME = "RNPermissions";

  private static int mRequestCode = 0;
  private static final String GRANTED = "granted";
  private static final String DENIED = "denied";
  private static final String UNAVAILABLE = "unavailable";
  private static final String BLOCKED = "blocked";

  public static Map<String, Object> getConstants() {
    HashMap<String, Object> constants = new HashMap<>();
    constants.put("available", Arguments.createArray());
    return constants;
  }

  private static boolean isPermissionUnavailable(@NonNull final String permission) {
    String fieldName = permission
      .replace("android.permission.", "")
      .replace("com.android.voicemail.permission.", "");

    try {
      Manifest.permission.class.getField(fieldName);
      return false;
    } catch (NoSuchFieldException ignored) {
      return true;
    }
  }

  // Only used on Android < 13 (the POST_NOTIFICATIONS runtime permission isn't available)
  private static WritableMap getLegacyNotificationsResponse(
    final ReactApplicationContext reactContext,
    final String disabledStatus
  ) {
    final boolean enabled = NotificationManagerCompat.from(reactContext).areNotificationsEnabled();
    final WritableMap output = Arguments.createMap();
    final WritableMap settings = Arguments.createMap();

    output.putString("status", enabled ? GRANTED : disabledStatus);
    output.putMap("settings", settings);

    return output;
  }

  public static void openSettings(
    final ReactApplicationContext reactContext,
    final Promise promise
  ) {
    try {
      final Intent intent = new Intent();
      final String packageName = reactContext.getPackageName();

      intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      intent.setData(Uri.fromParts("package", packageName, null));

      reactContext.startActivity(intent);
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  public static void check(
    final ReactApplicationContext reactContext,
    final String permission,
    final Promise promise
  ) {
    if (permission == null || isPermissionUnavailable(permission)) {
      promise.resolve(UNAVAILABLE);
      return;
    }

    Context context = reactContext.getBaseContext();

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      promise.resolve(context.checkPermission(permission, Process.myPid(), Process.myUid())
        == PackageManager.PERMISSION_GRANTED
        ? GRANTED
        : BLOCKED);
      return;
    }

    if (context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
      promise.resolve(GRANTED);
    } else {
      promise.resolve(DENIED);
    }
  }

  public static void checkNotifications(
    final ReactApplicationContext reactContext,
    final Promise promise
  ) {
    promise.resolve(getLegacyNotificationsResponse(reactContext, DENIED));
  }

  public static void checkMultiple(
    final ReactApplicationContext reactContext,
    final ReadableArray permissions,
    final Promise promise
  ) {
    final WritableMap output = new WritableNativeMap();
    Context context = reactContext.getBaseContext();

    for (int i = 0; i < permissions.size(); i++) {
      String permission = permissions.getString(i);

      if (isPermissionUnavailable(permission)) {
        output.putString(permission, UNAVAILABLE);
      } else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
        output.putString(
          permission,
          context.checkPermission(permission, Process.myPid(), Process.myUid())
            == PackageManager.PERMISSION_GRANTED
            ? GRANTED
            : BLOCKED);
      } else if (context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
        output.putString(permission, GRANTED);
      } else {
        output.putString(permission, DENIED);
      }
    }

    promise.resolve(output);
  }

  public static void request(
    final ReactApplicationContext reactContext,
    final PermissionListener listener,
    final SparseArray<Callback> callbacks,
    final String permission,
    final Promise promise
  ) {
    if (permission == null || isPermissionUnavailable(permission)) {
      promise.resolve(UNAVAILABLE);
      return;
    }

    Context context = reactContext.getBaseContext();

    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      promise.resolve(context.checkPermission(permission, Process.myPid(), Process.myUid())
        == PackageManager.PERMISSION_GRANTED
        ? GRANTED
        : BLOCKED);
      return;
    }

    if (context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
      promise.resolve(GRANTED);
      return;
    }

    try {
      PermissionAwareActivity activity = getPermissionAwareActivity(reactContext);

      callbacks.put(
        mRequestCode,
        new Callback() {
          @Override
          public void invoke(Object... args) {
            int[] results = (int[]) args[0];

            if (results.length > 0 && results[0] == PackageManager.PERMISSION_GRANTED) {
              promise.resolve(GRANTED);
            } else {
              PermissionAwareActivity activity = (PermissionAwareActivity) args[1];

              if (activity.shouldShowRequestPermissionRationale(permission)) {
                promise.resolve(DENIED);
              } else {
                promise.resolve(BLOCKED);
              }
            }
          }
        });

      activity.requestPermissions(new String[] {permission}, mRequestCode, listener);
      mRequestCode++;
    } catch (IllegalStateException e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  public static void requestNotifications(
    final ReactApplicationContext reactContext,
    final Promise promise
  ) {
    promise.resolve(getLegacyNotificationsResponse(reactContext, BLOCKED));
  }

  public static void requestMultiple(
    final ReactApplicationContext reactContext,
    final PermissionListener listener,
    final SparseArray<Callback> callbacks,
    final ReadableArray permissions,
    final Promise promise
  ) {
    final WritableMap output = new WritableNativeMap();
    final ArrayList<String> permissionsToCheck = new ArrayList<String>();
    int checkedPermissionsCount = 0;
    Context context = reactContext.getBaseContext();

    for (int i = 0; i < permissions.size(); i++) {
      String permission = permissions.getString(i);

      if (isPermissionUnavailable(permission)) {
        output.putString(permission, UNAVAILABLE);
        checkedPermissionsCount++;
      } else if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
        output.putString(
          permission,
          context.checkPermission(permission, Process.myPid(), Process.myUid())
            == PackageManager.PERMISSION_GRANTED
            ? GRANTED
            : BLOCKED);

        checkedPermissionsCount++;
      } else if (context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED) {
        output.putString(permission, GRANTED);
        checkedPermissionsCount++;
      } else {
        permissionsToCheck.add(permission);
      }
    }

    if (permissions.size() == checkedPermissionsCount) {
      promise.resolve(output);
      return;
    }

    try {
      PermissionAwareActivity activity = getPermissionAwareActivity(reactContext);

      callbacks.put(
        mRequestCode,
        new Callback() {
          @Override
          public void invoke(Object... args) {
            int[] results = (int[]) args[0];
            PermissionAwareActivity activity = (PermissionAwareActivity) args[1];

            for (int j = 0; j < permissionsToCheck.size(); j++) {
              String permission = permissionsToCheck.get(j);

              if (results.length > 0 && results[j] == PackageManager.PERMISSION_GRANTED) {
                output.putString(permission, GRANTED);
              } else {
                if (activity.shouldShowRequestPermissionRationale(permission)) {
                  output.putString(permission, DENIED);
                } else {
                  output.putString(permission, BLOCKED);
                }
              }
            }

            promise.resolve(output);
          }
        });

      activity.requestPermissions(permissionsToCheck.toArray(new String[0]), mRequestCode, listener);
      mRequestCode++;
    } catch (IllegalStateException e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  public static void shouldShowRequestRationale(
    final ReactApplicationContext reactContext,
    final String permission,
    final Promise promise
  ) {
    if (permission == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      promise.resolve(false);
      return;
    }

    try {
      promise.resolve(getPermissionAwareActivity(reactContext)
        .shouldShowRequestPermissionRationale(permission));
    } catch (IllegalStateException e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  private static PermissionAwareActivity getPermissionAwareActivity(
    final ReactApplicationContext reactContext
  ) {
    Activity activity = reactContext.getCurrentActivity();

    if (activity == null) {
      throw new IllegalStateException(
        "Tried to use permissions API while not attached to an " + "Activity.");
    } else if (!(activity instanceof PermissionAwareActivity)) {
      throw new IllegalStateException(
        "Tried to use permissions API but the host Activity doesn't"
          + " implement PermissionAwareActivity.");
    }

    return (PermissionAwareActivity) activity;
  }

  public static void openPhotoPicker(final Promise promise) {
    promise.reject("Permissions:openPhotoPicker", "openPhotoPicker is not supported on Android");
  }

  public static void checkLocationAccuracy(final Promise promise) {
    promise.reject("Permissions:checkLocationAccuracy", "checkLocationAccuracy is not supported on Android");
  }

  public static void requestLocationAccuracy(final Promise promise) {
    promise.reject("Permissions:requestLocationAccuracy", "requestLocationAccuracy is not supported on Android");
  }

  public static boolean onRequestPermissionsResult(
    final ReactApplicationContext reactContext,
    final SparseArray<Callback> callbacks,
    int requestCode,
    int[] grantResults
  ) {
    try {
      callbacks.get(requestCode).invoke(grantResults, getPermissionAwareActivity(reactContext));
      callbacks.remove(requestCode);
      return callbacks.size() == 0;
    } catch (Exception e) {
      FLog.e(
        "PermissionsModule",
        e,
        "Unexpected invocation of `onRequestPermissionsResult`");
      return false;
    }
  }
}
