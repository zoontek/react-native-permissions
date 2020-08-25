#import "RNPermissions.h"

@interface RNPermissionHandlerLocationFullAccuracy : NSObject<RNPermissionHandler>

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys;

+ (NSString * _Nonnull)handlerUniqueId;

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus status))resolve
                 rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject;

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus status))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject;

- (void)requestTemporaryWithResolver:(void (^ _Nonnull)(RNPermissionStatus status))resolve
                            rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject
                          purposeKey:(NSString * _Nonnull)purposeKey;

@end
