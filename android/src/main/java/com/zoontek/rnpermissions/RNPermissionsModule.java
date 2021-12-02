package com.zoontek.rnpermissions;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Process;
import android.provider.Settings;
import android.util.SparseArray;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationManagerCompat;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.module.annotations.ReactModule;
import com.facebook.react.modules.core.PermissionAwareActivity;
import com.facebook.react.modules.core.PermissionListener;

import java.util.ArrayList;

@ReactModule(name = RNPermissionsModule.MODULE_NAME)
public class RNPermissionsModule extends ReactContextBaseJavaModule implements PermissionListener {

  private static final String ERROR_INVALID_ACTIVITY = "E_INVALID_ACTIVITY";
  public static final String MODULE_NAME = "RNPermissions";
  private static final String SETTING_NAME = "@RNPermissions:NonRequestables";

  private final SharedPreferences mSharedPrefs;
  private final SparseArray<Request> mRequests;
  private int mRequestCode = 0;
  private final String GRANTED = "granted";
  private final String DENIED = "denied";
  private final String UNAVAILABLE = "unavailable";
  private final String BLOCKED = "blocked";

  public RNPermissionsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    mSharedPrefs = reactContext.getSharedPreferences(SETTING_NAME, Context.MODE_PRIVATE);
    mRequests = new SparseArray<Request>();
  }

  @Override
  public String getName() {
    return MODULE_NAME;
  }

  private class Request {

    public boolean[] rationaleStatuses;
    public Callback callback;

    public Request(boolean[] rationaleStatuses, Callback callback) {
      this.rationaleStatuses = rationaleStatuses;
      this.callback = callback;
    }
  }

  private @Nullable String getFieldName(final String permission) {
    if (permission.equals("android.permission.ACCEPT_HANDOVER"))
      return "ACCEPT_HANDOVER";
    if (permission.equals("android.permission.ACCESS_BACKGROUND_LOCATION"))
      return "ACCESS_BACKGROUND_LOCATION";
    if (permission.equals("android.permission.ACCESS_COARSE_LOCATION"))
      return "ACCESS_COARSE_LOCATION";
    if (permission.equals("android.permission.ACCESS_FINE_LOCATION"))
      return "ACCESS_FINE_LOCATION";
    if (permission.equals("android.permission.ACCESS_MEDIA_LOCATION"))
      return "ACCESS_MEDIA_LOCATION";
    if (permission.equals("com.android.voicemail.permission.ADD_VOICEMAIL"))
      return "ADD_VOICEMAIL";
    if (permission.equals("android.permission.ACTIVITY_RECOGNITION"))
      return "ACTIVITY_RECOGNITION";
    if (permission.equals("android.permission.ANSWER_PHONE_CALLS"))
      return "ANSWER_PHONE_CALLS";
    if (permission.equals("android.permission.BLUETOOTH_ADVERTISE"))
      return "BLUETOOTH_ADVERTISE";
    if (permission.equals("android.permission.BLUETOOTH_CONNECT"))
      return "BLUETOOTH_CONNECT";
    if (permission.equals("android.permission.BLUETOOTH_SCAN"))
      return "BLUETOOTH_SCAN";
    if (permission.equals("android.permission.BODY_SENSORS"))
      return "BODY_SENSORS";
    if (permission.equals("android.permission.CALL_PHONE"))
      return "CALL_PHONE";
    if (permission.equals("android.permission.CAMERA"))
      return "CAMERA";
    if (permission.equals("android.permission.GET_ACCOUNTS"))
      return "GET_ACCOUNTS";
    if (permission.equals("android.permission.PROCESS_OUTGOING_CALLS"))
      return "PROCESS_OUTGOING_CALLS";
    if (permission.equals("android.permission.READ_CALENDAR"))
      return "READ_CALENDAR";
    if (permission.equals("android.permission.READ_CALL_LOG"))
      return "READ_CALL_LOG";
    if (permission.equals("android.permission.READ_CONTACTS"))
      return "READ_CONTACTS";
    if (permission.equals("android.permission.READ_EXTERNAL_STORAGE"))
      return "READ_EXTERNAL_STORAGE";
    if (permission.equals("android.permission.READ_PHONE_NUMBERS"))
      return "READ_PHONE_NUMBERS";
    if (permission.equals("android.permission.READ_PHONE_STATE"))
      return "READ_PHONE_STATE";
    if (permission.equals("android.permission.READ_SMS"))
      return "READ_SMS";
    if (permission.equals("android.permission.RECEIVE_MMS"))
      return "RECEIVE_MMS";
    if (permission.equals("android.permission.RECEIVE_SMS"))
      return "RECEIVE_SMS";
    if (permission.equals("android.permission.RECEIVE_WAP_PUSH"))
      return "RECEIVE_WAP_PUSH";
    if (permission.equals("android.permission.RECORD_AUDIO"))
      return "RECORD_AUDIO";
    if (permission.equals("android.permission.SEND_SMS"))
      return "SEND_SMS";
    if (permission.equals("android.permission.USE_SIP"))
      return "USE_SIP";
    if (permission.equals("android.permission.WRITE_CALENDAR"))
      return "WRITE_CALENDAR";
    if (permission.equals("android.permission.WRITE_CALL_LOG"))
      return "WRITE_CALL_LOG";
    if (permission.equals("android.permission.WRITE_CONTACTS"))
      return "WRITE_CONTACTS";
    if (permission.equals("android.permission.WRITE_EXTERNAL_STORAGE"))
      return "WRITE_EXTERNAL_STORAGE";

    return null;
  }

  private boolean permissionExists(final String permission) {
    String fieldName = getFieldName(permission);

    if (fieldName == null)
      return false;

    try {
      Manifest.permission.class.getField(fieldName);
      return true;
    } catch (NoSuchFieldException ignored) {
      return false;
    }
  }

  @ReactMethod
  public void checkNotifications(final Promise promise) {
    final boolean enabled = NotificationManagerCompat
      .from(getReactApplicationContext()).areNotificationsEnabled();
    final WritableMap output = Arguments.createMap();
    final WritableMap settings = Arguments.createMap();

    if (enabled) {
      output.putString("status", "granted");
    } else {
      output.putString("status", "blocked");
    }

    output.putMap("settings", settings);
    promise.resolve(output);
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
  public void checkPermission(final String permission, final Promise promise) {
    if (permission == null || !permissionExists(permission)) {
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
    } else if (mSharedPrefs.getBoolean(permission, false)) {
      promise.resolve(BLOCKED);
    } else {
      promise.resolve(DENIED);
    }
  }

  @ReactMethod
  public void shouldShowRequestPermissionRationale(final String permission, final Promise promise) {
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
  public void requestPermission(final String permission, final Promise promise) {
    if (permission == null || !permissionExists(permission)) {
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
    } else if (mSharedPrefs.getBoolean(permission, false)) {
      promise.resolve(BLOCKED); // not supporting reset the permission with "Ask me every time"
      return;
    }

    try {
      PermissionAwareActivity activity = getPermissionAwareActivity();
      boolean[] rationaleStatuses = new boolean[1];
      rationaleStatuses[0] = activity.shouldShowRequestPermissionRationale(permission);

      mRequests.put(mRequestCode, new Request(
        rationaleStatuses,
        new Callback() {
          @SuppressLint("ApplySharedPref")
          @Override
          public void invoke(Object... args) {
            int[] results = (int[]) args[0];

            if (results.length > 0 && results[0] == PackageManager.PERMISSION_GRANTED) {
              promise.resolve(GRANTED);
            } else {
              PermissionAwareActivity activity = (PermissionAwareActivity) args[1];
              boolean[] rationaleStatuses = (boolean[]) args[2];

              if (rationaleStatuses[0] &&
                !activity.shouldShowRequestPermissionRationale(permission)) {
                mSharedPrefs.edit().putBoolean(permission, true).commit(); // enforce sync
                promise.resolve(BLOCKED);
              } else {
                promise.resolve(DENIED);
              }
            }
          }
        }));

      activity.requestPermissions(new String[] {permission}, mRequestCode, this);
      mRequestCode++;
    } catch (IllegalStateException e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  @ReactMethod
  public void checkMultiplePermissions(final ReadableArray permissions, final Promise promise) {
    final WritableMap output = new WritableNativeMap();
    Context context = getReactApplicationContext().getBaseContext();

    for (int i = 0; i < permissions.size(); i++) {
      String permission = permissions.getString(i);

      if (!permissionExists(permission)) {
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
      } else if (mSharedPrefs.getBoolean(permission, false)) {
        output.putString(permission, BLOCKED); // not supporting reset the permission with "Ask me every time"
      } else {
        output.putString(permission, DENIED);
      }
    }

    promise.resolve(output);
  }

  @ReactMethod
  public void requestMultiplePermissions(final ReadableArray permissions, final Promise promise) {
    final WritableMap output = new WritableNativeMap();
    final ArrayList<String> permissionsToCheck = new ArrayList<String>();
    int checkedPermissionsCount = 0;

    Context context = getReactApplicationContext().getBaseContext();

    for (int i = 0; i < permissions.size(); i++) {
      String permission = permissions.getString(i);

      if (!permissionExists(permission)) {
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
      } else if (mSharedPrefs.getBoolean(permission, false)) {
        output.putString(permission, BLOCKED); // not supporting reset the permission with "Ask me every time"
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
      boolean[] rationaleStatuses = new boolean[permissionsToCheck.size()];

      for (int i = 0; i < permissionsToCheck.size(); i++) {
        rationaleStatuses[i] = activity
          .shouldShowRequestPermissionRationale(permissionsToCheck.get(i));
      }

      mRequests.put(mRequestCode, new Request(
        rationaleStatuses,
        new Callback() {
          @SuppressLint("ApplySharedPref")
          @Override
          public void invoke(Object... args) {
            int[] results = (int[]) args[0];
            PermissionAwareActivity activity = (PermissionAwareActivity) args[1];
            boolean[] rationaleStatuses = (boolean[]) args[2];

            for (int j = 0; j < permissionsToCheck.size(); j++) {
              String permission = permissionsToCheck.get(j);

              if (results.length > 0 && results[j] == PackageManager.PERMISSION_GRANTED) {
                output.putString(permission, GRANTED);
              } else {
                if (rationaleStatuses[j] &&
                  !activity.shouldShowRequestPermissionRationale(permission)) {
                  mSharedPrefs.edit().putBoolean(permission, true).commit(); // enforce sync
                  output.putString(permission, BLOCKED);
                } else {
                  output.putString(permission, DENIED);
                }
              }
            }

            promise.resolve(output);
          }
        }));

      activity.requestPermissions(permissionsToCheck.toArray(new String[0]), mRequestCode, this);
      mRequestCode++;
    } catch (IllegalStateException e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    Request request = mRequests.get(requestCode);
    request.callback.invoke(grantResults, getPermissionAwareActivity(), request.rationaleStatuses);
    mRequests.remove(requestCode);
    return mRequests.size() == 0;
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
