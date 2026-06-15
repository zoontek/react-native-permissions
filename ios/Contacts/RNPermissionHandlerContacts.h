#import "RNPermissions.h"

@interface RNPermissionHandlerContacts : NSObject<RNPermissionHandler>

- (void)openContactPickerWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                              rejecter:(RCTPromiseRejectBlock _Nonnull)reject;

@end
