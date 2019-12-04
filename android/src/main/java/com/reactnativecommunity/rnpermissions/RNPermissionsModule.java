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

import java.util.Map;

@ReactModule(name = RNPermissionsModule.MODULE_NAME)
public class RNPermissionsModule extends ReactContextBaseJavaModule {

  private static final String ERROR_INVALID_ACTIVITY = "E_INVALID_ACTIVITY";
  public static final String MODULE_NAME = "RNPermissions";
  private static final String SETTING_NAME = "@RNPermissions:NonRequestables";

  private final SharedPreferences sharedPrefs;

  public RNPermissionsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    sharedPrefs = reactContext.getSharedPreferences(SETTING_NAME, Context.MODE_PRIVATE);
  }

  @Override
  public String getName() {
    return MODULE_NAME;
  }

  @ReactMethod
  public void isAvailable(final String permission, final Promise promise) {
    String fieldName = permission.substring(permission.lastIndexOf('.') + 1);

    try {
      Manifest.permission.class.getField(fieldName);
      promise.resolve(true);
    } catch (NoSuchFieldException e) {
      promise.resolve(false);
    }
  }

  @ReactMethod
  public void setNonRequestable(final String permission, final Promise promise) {
    promise.resolve(sharedPrefs.edit().putBoolean(permission, true).commit());
  }

  @ReactMethod
  public void getNonRequestables(final Promise promise) {
    WritableArray result = Arguments.createArray();
    Map<String, ?> entries = sharedPrefs.getAll();

    for (Map.Entry<String, ?> entry : entries.entrySet()) {
      result.pushString(entry.getKey());
    }

    promise.resolve(result);
  }

  @ReactMethod
  public void openSettings(final Promise promise) {
    try {
      final ReactApplicationContext reactContext = getReactApplicationContext();
      final Intent intent = new Intent();

      intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
      intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
      intent.setData(Uri.fromParts("package", reactContext.getPackageName(), null));

      reactContext.startActivity(intent);
      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }

  private WritableMap internalCheckNotifications() {
    final ReactApplicationContext reactContext = getReactApplicationContext();
    final boolean enabled = NotificationManagerCompat.from(reactContext).areNotificationsEnabled();
    final WritableMap map = Arguments.createMap();
    final WritableMap settings = Arguments.createMap();

    if (enabled) {
      map.putString("status", "granted");
    } else {
      map.putString("status", "blocked");
    }

    map.putMap("settings", settings);
    return map;
  }

  @ReactMethod
  public void checkNotifications(final Promise promise) {
    promise.resolve(internalCheckNotifications());
  }

  @ReactMethod
  public void requestNotifications(ReadableArray options, final Promise promise) {
    promise.resolve(internalCheckNotifications());
  }
}
