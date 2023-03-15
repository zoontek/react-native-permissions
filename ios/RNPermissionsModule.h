#ifdef RCT_NEW_ARCH_ENABLED
#import <rnpermissions/rnpermissions.h>
#else
#import <React/RCTBridge.h>
#endif

#import <React/RCTConvert.h>
#import "RNPermissionsHelper.h"

@interface RCTConvert (RNPermission)

@end

#ifdef RCT_NEW_ARCH_ENABLED
@interface RNPermissionsModule : NSObject<NativePermissionsModuleSpec>
#else
@interface RNPermissionsModule : NSObject<RCTBridgeModule>
#endif

@end
