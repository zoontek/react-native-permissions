#import "RNPermissions.h"

@interface RNPermissionHandlerContacts : NSObject<RNPermissionHandler>

- (void)openContactsPickerWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                              rejecter:(RCTPromiseRejectBlock _Nonnull)reject;

@end
