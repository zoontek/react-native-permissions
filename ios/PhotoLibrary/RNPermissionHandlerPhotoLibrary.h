#import "RNPermissions.h"

@interface RNPermissionHandlerPhotoLibrary : NSObject<RNPermissionHandler>

- (void)presentLimitedLibraryPickerFromViewController API_AVAILABLE(ios(14));

@end
