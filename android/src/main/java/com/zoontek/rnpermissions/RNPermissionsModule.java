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
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@ReactModule(name = RNPermissionsModule.NAME)
public class RNPermissionsModule extends NativePermissionsModuleSpec implements PermissionListener {

  private static final String ERROR_INVALID_ACTIVITY = "E_INVALID_ACTIVITY";
  public static final String NAME = "RNPermissionsModule";

  private final SparseArray<Callback> mCallbacks;
  private int mRequestCode = 0;
  private final String GRANTED = "granted";
  private final String DENIED = "denied";
  private final String UNAVAILABLE = "unavailable";
  private final String BLOCKED = "blocked";

  public RNPermissionsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    mCallbacks = new SparseArray<Callback>();
  }

  @Override
  public String getName() {
    return NAME;
  }

  private boolean isPermissionUnavailable(@NonNull final String permission) {
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
  private WritableMap getLegacyNotificationsResponse(String disabledStatus) {
    final boolean enabled = NotificationManagerCompat
      .from(getReactApplicationContext()).areNotificationsEnabled();

    final WritableMap output = Arguments.createMap();
    final WritableMap settings = Arguments.createMap();

    output.putString("status", enabled ? GRANTED : disabledStatus);
    output.putMap("settings", settings);

    return output;
  }

  @ReactMethod
  public void checkNotifications(final Promise promise) {
    promise.resolve(getLegacyNotificationsResponse(DENIED));
  }

  @Override
  public void requestNotifications(final ReadableArray options, final Promise promise) {
    promise.resolve(getLegacyNotificationsResponse(BLOCKED));
  }

  @ReactMethod
  public void openSettings(final Promise promise) {
    try {
      final ReactApplicationContext reactContext = getReactApplicationContext();
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

  @ReactMethod
  public void check(final String permission, final Promise promise) {
    if (permission == null || isPermissionUnavailable(permission)) {
      promise.resolve(UNAVAILABLE);
      return;
    }

    Context context = getReactApplicationContext().getBaseContext();

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

  @ReactMethod
  public void shouldShowRequestRationale(final String permission, final Promise promise) {
    if (permission == null || Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
      promise.resolve(false);
      return;
    }

    try {
      promise.resolve(
        getPermissionAwareActivity().shouldShowRequestPermissionRationale(permission));
    } catch (IllegalStateException e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  @ReactMethod
  public void request(final String permission, final Promise promise) {
    if (permission == null || isPermissionUnavailable(permission)) {
      promise.resolve(UNAVAILABLE);
      return;
    }

    Context context = getReactApplicationContext().getBaseContext();

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
      PermissionAwareActivity activity = getPermissionAwareActivity();

      mCallbacks.put(
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

      activity.requestPermissions(new String[] {permission}, mRequestCode, this);
      mRequestCode++;
    } catch (IllegalStateException e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  @ReactMethod
  public void checkMultiple(final ReadableArray permissions, final Promise promise) {
    final WritableMap output = new WritableNativeMap();
    Context context = getReactApplicationContext().getBaseContext();

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

  @ReactMethod
  public void requestMultiple(final ReadableArray permissions, final Promise promise) {
    final WritableMap output = new WritableNativeMap();
    final ArrayList<String> permissionsToCheck = new ArrayList<String>();
    int checkedPermissionsCount = 0;
    Context context = getReactApplicationContext().getBaseContext();

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
      PermissionAwareActivity activity = getPermissionAwareActivity();

      mCallbacks.put(
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

      activity.requestPermissions(permissionsToCheck.toArray(new String[0]), mRequestCode, this);
      mRequestCode++;
    } catch (IllegalStateException e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  @Override
  protected Map<String, Object> getTypedExportedConstants() {
    return new HashMap<>();
  }

  @Override
  public void checkLocationAccuracy(Promise promise) {
    promise.reject("Permissions:checkLocationAccuracy", "checkLocationAccuracy is not supported on Android");
  }

  @Override
  public void requestLocationAccuracy(String purposeKey, Promise promise) {
    promise.reject("Permissions:requestLocationAccuracy", "requestLocationAccuracy is not supported on Android");
  }

  @Override
  public void openPhotoPicker(Promise promise) {
    promise.reject("Permissions:openPhotoPicker", "openPhotoPicker is not supported on Android");
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    try {
      mCallbacks.get(requestCode).invoke(grantResults, getPermissionAwareActivity());
      mCallbacks.remove(requestCode);
      return mCallbacks.size() == 0;
    } catch (Exception e) {
      FLog.e(
        "PermissionsModule",
        e,
        "Unexpected invocation of `onRequestPermissionsResult`");
      return false;
    }
  }

  private PermissionAwareActivity getPermissionAwareActivity() {
    Activity activity = getCurrentActivity();

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
}
