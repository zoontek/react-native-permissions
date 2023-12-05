#import "RNPermissionsModule.h"

@interface RNPermissionHandlerLocationAccuracy : NSObject

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys;

+ (NSString * _Nonnull)handlerUniqueId;

- (void)checkWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                 rejecter:(RCTPromiseRejectBlock _Nonnull)reject;

- (void)requestWithPurposeKey:(NSString * _Nonnull)purposeKey
                     resolver:(RCTPromiseResolveBlock _Nonnull)resolve
                     rejecter:(RCTPromiseRejectBlock _Nonnull)reject;

@end
