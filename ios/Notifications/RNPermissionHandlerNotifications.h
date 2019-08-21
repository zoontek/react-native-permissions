#import "RNPermissions.h"

@interface RNPermissionHandlerNotifications : NSObject<RNPermissionHandler, RNPermissionWithRequestOptions>

- (void)getSettingsWithResolver:(void (^ _Nonnull)(NSDictionary * _Nonnull settings))resolve;

@end
