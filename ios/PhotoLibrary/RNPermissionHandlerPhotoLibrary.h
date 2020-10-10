#import "RNPermissions.h"

@interface RNPermissionHandlerPhotoLibrary : NSObject<RNPermissionHandler>

- (void)openLimitedPhotoLibraryPickerWithResolver:(RCTPromiseResolveBlock)resolve
                                         rejecter:(RCTPromiseRejectBlock)reject;

@end
