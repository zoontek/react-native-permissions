#ifdef RCT_NEW_ARCH_ENABLED
#import <rnpermissions/rnpermissions.h>
#else
#import <React/RCTBridge.h>
#endif
#import <React/RCTConvert.h>
#import "RNPermissionsHelper.h"

@interface RCTConvert (RNPermission)
@end

@interface RNPermissionsModule : NSObject
#ifdef RCT_NEW_ARCH_ENABLED
                                   <NativePermissionsModuleSpec>
#else
                                   <RCTBridgeModule>
#endif

@end
