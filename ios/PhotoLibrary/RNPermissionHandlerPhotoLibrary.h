#import "RNPermissionsHelper.h"

@interface RNPermissionHandlerPhotoLibrary : NSObject<RNPermissionHandler>

- (void)openLimitedPhotoLibraryPickerWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                                         rejecter:(RCTPromiseRejectBlock _Nonnull)reject;

@end
