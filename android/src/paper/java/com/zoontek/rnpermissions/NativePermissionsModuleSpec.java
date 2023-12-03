
/**
 * This code was generated by [react-native-codegen](https://www.npmjs.com/package/react-native-codegen).
 *
 * Do not edit this file as changes may cause incorrect behavior and will be lost
 * once the code is regenerated.
 *
 * @generated by codegen project: GenerateModuleJavaSpec.js
 *
 * @nolint
 */

package com.zoontek.rnpermissions;

import com.facebook.proguard.annotations.DoNotStrip;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReactModuleWithSpec;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.common.build.ReactBuildConfig;
import com.facebook.react.turbomodule.core.interfaces.TurboModule;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.annotation.Nullable;

public abstract class NativePermissionsModuleSpec extends ReactContextBaseJavaModule implements ReactModuleWithSpec, TurboModule {
  public NativePermissionsModuleSpec(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @ReactMethod
  @DoNotStrip
  public abstract void openSettings(Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void checkNotifications(Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void checkPermission(String permission, Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void shouldShowRequestPermissionRationale(String permission, Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void requestPermission(String permission, Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void checkMultiplePermissions(ReadableArray permissions, Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void requestMultiplePermissions(ReadableArray permissions, Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void check(String permission, Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void checkLocationAccuracy(Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void request(String permission, Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void requestLocationAccuracy(String purposeKey, Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void requestNotifications(ReadableArray options, Promise promise);

  @ReactMethod
  @DoNotStrip
  public abstract void openPhotoPicker(Promise promise);

  protected abstract Map<String, Object> getTypedExportedConstants();

  @Override
  @DoNotStrip
  public final @Nullable Map<String, Object> getConstants() {
    Map<String, Object> constants = getTypedExportedConstants();

    if (ReactBuildConfig.DEBUG || ReactBuildConfig.IS_INTERNAL_BUILD) {
      Set<String> obligatoryFlowConstants = new HashSet<>();
      Set<String> optionalFlowConstants = new HashSet<>(List.of("available"));
      Set<String> undeclaredConstants = new HashSet<>(constants.keySet());

      undeclaredConstants.removeAll(obligatoryFlowConstants);
      undeclaredConstants.removeAll(optionalFlowConstants);

      if (!undeclaredConstants.isEmpty()) {
        throw new IllegalStateException(String.format("Native Module Flow doesn't declare constants: %s", undeclaredConstants));
      }

      undeclaredConstants = obligatoryFlowConstants;
      undeclaredConstants.removeAll(constants.keySet());

      if (!undeclaredConstants.isEmpty()) {
        throw new IllegalStateException(String.format("Native Module doesn't fill in constants: %s", undeclaredConstants));
      }
    }

    return constants;
  }
}
