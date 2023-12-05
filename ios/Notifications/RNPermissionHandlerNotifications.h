#import "RNPermissionsModule.h"

@interface RNPermissionHandlerNotifications : NSObject

+ (NSString * _Nonnull)handlerUniqueId;

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve
                 rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject;

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject
                    options:(NSArray<NSString *> * _Nonnull)options;

@end
