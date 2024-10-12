package com.zoontek.rnpermissions

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class RNPermissionsPackage : TurboReactPackage() {
  override fun getModule(name: String, reactContext: ReactApplicationContext): NativeModule? {
    return when (name) {
      RNPermissionsModuleImpl.NAME -> RNPermissionsModule(reactContext)
      else -> null
    }
  }

  override fun getReactModuleInfoProvider(): ReactModuleInfoProvider {
    return ReactModuleInfoProvider {
      val moduleInfos: MutableMap<String, ReactModuleInfo> = HashMap()
      val isTurboModule = BuildConfig.IS_NEW_ARCHITECTURE_ENABLED

      val moduleInfo = ReactModuleInfo(
        RNPermissionsModuleImpl.NAME,
        RNPermissionsModuleImpl.NAME,
        false,
        false,
        true,
        false,
        isTurboModule
      )

      moduleInfos[RNPermissionsModuleImpl.NAME] = moduleInfo
      moduleInfos
    }
  }
}
