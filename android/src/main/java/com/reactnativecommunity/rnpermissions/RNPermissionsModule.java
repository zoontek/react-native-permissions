package com.reactnativecommunity.rnpermissions;

import android.Manifest;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.provider.Settings;

import androidx.core.app.NotificationManagerCompat;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.module.annotations.ReactModule;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

@ReactModule(name = RNPermissionsModule.MODULE_NAME)
public class RNPermissionsModule extends ReactContextBaseJavaModule {

  private static final String ERROR_INVALID_ACTIVITY = "E_INVALID_ACTIVITY";
  public static final String MODULE_NAME = "RNPermissions";
  private static final String SETTING_NAME = "@RNPermissions:NonRequestables";

  private static final String[][] PERMISSIONS = new String[][] {
    { "ACCEPT_HANDOVER", "android.permission.ACCEPT_HANDOVER" },
    { "ACCESS_BACKGROUND_LOCATION", "android.permission.ACCESS_BACKGROUND_LOCATION" },
    { "ACCESS_COARSE_LOCATION", "android.permission.ACCESS_COARSE_LOCATION" },
    { "ACCESS_FINE_LOCATION", "android.permission.ACCESS_FINE_LOCATION" },
    { "ACTIVITY_RECOGNITION", "android.permission.ACTIVITY_RECOGNITION" },
    { "ADD_VOICEMAIL", "com.android.voicemail.permission.ADD_VOICEMAIL" },
    { "ANSWER_PHONE_CALLS", "android.permission.ANSWER_PHONE_CALLS" },
    { "BODY_SENSORS", "android.permission.BODY_SENSORS" },
    { "CALL_PHONE", "android.permission.CALL_PHONE" },
    { "CAMERA", "android.permission.CAMERA" },
    { "GET_ACCOUNTS", "android.permission.GET_ACCOUNTS" },
    { "PROCESS_OUTGOING_CALLS", "android.permission.PROCESS_OUTGOING_CALLS" },
    { "READ_CALENDAR", "android.permission.READ_CALENDAR" },
    { "READ_CALL_LOG", "android.permission.READ_CALL_LOG" },
    { "READ_CONTACTS", "android.permission.READ_CONTACTS" },
    { "READ_EXTERNAL_STORAGE", "android.permission.READ_EXTERNAL_STORAGE" },
    { "READ_PHONE_NUMBERS", "android.permission.READ_PHONE_NUMBERS" },
    { "READ_PHONE_STATE", "android.permission.READ_PHONE_STATE" },
    { "READ_SMS", "android.permission.READ_SMS" },
    { "RECEIVE_MMS", "android.permission.RECEIVE_MMS" },
    { "RECEIVE_SMS", "android.permission.RECEIVE_SMS" },
    { "RECEIVE_WAP_PUSH", "android.permission.RECEIVE_WAP_PUSH" },
    { "RECORD_AUDIO", "android.permission.RECORD_AUDIO" },
    { "SEND_SMS", "android.permission.SEND_SMS" },
    { "USE_SIP", "android.permission.USE_SIP" },
    { "WRITE_CALENDAR", "android.permission.WRITE_CALENDAR" },
    { "WRITE_CALL_LOG", "android.permission.WRITE_CALL_LOG" },
    { "WRITE_CONTACTS", "android.permission.WRITE_CONTACTS" },
    { "WRITE_EXTERNAL_STORAGE", "android.permission.WRITE_EXTERNAL_STORAGE" },
  };

  private final SharedPreferences sharedPrefs;

  public RNPermissionsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    sharedPrefs = reactContext.getSharedPreferences(SETTING_NAME, Context.MODE_PRIVATE);
  }

  @Override
  public String getName() {
    return MODULE_NAME;
  }

  private boolean fieldExists(final String fieldName) {
    try {
      Manifest.permission.class.getField(fieldName);
      return true;
    } catch (NoSuchFieldException ignored) {
      return false;
    }
  }

  @Override
  public @Nullable Map<String, Object> getConstants() {
    HashMap<String, Object> constants = new HashMap<>();
    WritableArray available = Arguments.createArray();

    for (String[] permission : PERMISSIONS) {
      if (fieldExists(permission[0]))
        available.pushString(permission[1]);
    }

    constants.put("available", available);
    return constants;
  }

  @ReactMethod
  public void isNonRequestable(final String permission, final Promise promise) {
    promise.resolve(sharedPrefs.getBoolean(permission, false));
  }

  @ReactMethod
  public void getNonRequestables(final Promise promise) {
    WritableArray output = Arguments.createArray();
    Map<String, ?> entries = sharedPrefs.getAll();

    for (Map.Entry<String, ?> entry : entries.entrySet())
      output.pushString(entry.getKey());

    promise.resolve(output);
  }

  @ReactMethod
  public void setNonRequestable(final String permission, final Promise promise) {
    promise.resolve(sharedPrefs.edit().putBoolean(permission, true).commit());
  }

  @ReactMethod
  public void setNonRequestables(final ReadableArray permissions, final Promise promise) {
    SharedPreferences.Editor editor = sharedPrefs.edit();

    for (int i = 0; i < permissions.size(); i++)
      editor.putBoolean(permissions.getString(i), true);

    promise.resolve(editor.commit());
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
}
