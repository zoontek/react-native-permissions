#import "RNPermissionsModule.h"

@interface RNPermissionHandlerPhotoLibrary : NSObject<RNPermissionHandler>

- (void)openPhotoPickerWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                           rejecter:(RCTPromiseRejectBlock _Nonnull)reject;

@end
