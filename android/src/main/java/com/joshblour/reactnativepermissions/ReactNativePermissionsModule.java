package com.joshblour.reactnativepermissions;

import android.Manifest;
import android.content.Intent;
import android.net.Uri;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.support.v4.content.PermissionChecker;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.PromiseImpl;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.modules.permissions.PermissionsModule;


public class ReactNativePermissionsModule extends ReactContextBaseJavaModule {
  private final ReactApplicationContext reactContext;
  private final PermissionsModule mPermissionsModule;

  public enum RNType {
    LOCATION,
    CAMERA,
    MICROPHONE,
    CONTACTS,
    EVENT,
    PHOTO;
  }

  public ReactNativePermissionsModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    mPermissionsModule = new PermissionsModule(this.reactContext);
  }

  @Override
  public String getName() {
    return "ReactNativePermissions";
  }

  @ReactMethod
  public void getPermissionStatus(String permissionString, Promise promise) {
    String permission = permissionForString(permissionString);

    // check if permission is valid
    if (permission == null) {
      promise.reject("unknown-permission", "ReactNativePermissions: unknown permission type - " + permissionString);
      return;
    }

    int result = PermissionChecker.checkSelfPermission(this.reactContext, permission);
    switch (result) {
      case PermissionChecker.PERMISSION_DENIED:
        // PermissionDenied could also mean that we've never asked for permission yet.
        // Use shouldShowRequestPermissionRationale to determined which on it is.
        if (getCurrentActivity() != null) {
          boolean deniedOnce = ActivityCompat.shouldShowRequestPermissionRationale(getCurrentActivity(), permission);
          promise.resolve(deniedOnce ? "denied" : "undetermined");
        } else {
          promise.resolve("denied");
        }
        break;
      case PermissionChecker.PERMISSION_DENIED_APP_OP:
        promise.resolve("denied");
        break;
      case PermissionChecker.PERMISSION_GRANTED:
        promise.resolve("authorized");
        break;
      default:
        promise.resolve("undetermined");
        break;
    }
  }

  @ReactMethod
  public void requestPermission(final String permissionString, String nullForiOSCompat, final Promise promise) {
    String permission = permissionForString(permissionString);
    Callback resolve = new Callback() {
      @Override
      public void invoke(Object... args) {
        getPermissionStatus(permissionString, promise);
      }
    };
    Callback reject = new Callback() {
      @Override
      public void invoke(Object... args) {
        // NOOP
      }
    };
    mPermissionsModule.requestPermission(permission, new PromiseImpl(resolve, reject));
  }


  @ReactMethod
  public void canOpenSettings(Promise promise) {
    promise.resolve(true);
  }

  @ReactMethod
  public void openSettings() {
    final Intent i = new Intent();
    i.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
    i.addCategory(Intent.CATEGORY_DEFAULT);
    i.setData(Uri.parse("package:" + this.reactContext.getPackageName()));
    i.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    i.addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
    i.addFlags(Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS);
    this.reactContext.startActivity(i);
  }

  private String permissionForString(String permission) {
    switch (RNType.valueOf(permission.toUpperCase())) {
      case LOCATION:
        return Manifest.permission.ACCESS_FINE_LOCATION;
      case CAMERA:
        return Manifest.permission.CAMERA;
      case MICROPHONE:
        return Manifest.permission.RECORD_AUDIO;
      case CONTACTS:
        return Manifest.permission.READ_CONTACTS;
      case EVENT:
        return Manifest.permission.READ_CALENDAR;
      case PHOTO:
        return Manifest.permission.READ_EXTERNAL_STORAGE;
      default:
        return null;
    }
  }

}
