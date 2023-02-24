#ifdef RCT_NEW_ARCH_ENABLED
#import <rnpermission/rnpermission.h>
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
