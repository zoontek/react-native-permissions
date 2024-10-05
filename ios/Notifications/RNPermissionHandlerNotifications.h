#import "RNPermissions.h"

@interface RNPermissionHandlerNotifications : NSObject

+ (NSString * _Nonnull)handlerUniqueId;

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve;

- (void)requestWithOptions:(NSArray<NSString *> * _Nonnull)options
                  resolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve
                  rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject;

@end
