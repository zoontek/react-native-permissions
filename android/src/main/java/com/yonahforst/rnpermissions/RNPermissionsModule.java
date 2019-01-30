package com.yonahforst.rnpermissions;

import android.Manifest;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class RNPermissionsModule extends ReactContextBaseJavaModule {

  private static final String ERROR_INVALID_ACTIVITY = "E_INVALID_ACTIVITY";

  public RNPermissionsModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "RNPermissions";
  }

  @ReactMethod
  public void isPermissionAvailable(final String permission, final Promise promise) {
    String fieldName = permission.substring(permission.lastIndexOf('.') + 1);

    try {
      Manifest.permission.class.getField(fieldName);
      promise.resolve(true);
    } catch (NoSuchFieldException e) {
      promise.resolve(false);
    }
  }

  @ReactMethod
  public void openSettings(final Promise promise) {
    try {
      String packageName = getReactApplicationContext().getPackageName();
      Intent intent = new Intent();
      intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
      intent.setData(Uri.fromParts("package", packageName , null));
      getReactApplicationContext().startActivity(intent);

      promise.resolve(true);
    } catch (Exception e) {
      promise.reject(ERROR_INVALID_ACTIVITY, e);
    }
  }
}
