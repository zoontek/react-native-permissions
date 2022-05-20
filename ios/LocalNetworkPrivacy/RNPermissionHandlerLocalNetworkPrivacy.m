#import "RNPermissionHandlerLocalNetworkPrivacy.h"
#import "LocalNetworkPrivacy.h"

@implementation RNPermissionHandlerLocalNetworkPrivacy

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSLocalNetworkUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.LOCAL_NETWORK_PRIVACY";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([LocalNetworkPrivacy authorizationStatus]) {
    case OptionalBoolNone:
      return resolve(RNPermissionStatusNotDetermined);
    case OptionalBoolNo:
      return resolve(RNPermissionStatusDenied);
    case OptionalBoolYes:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  LocalNetworkPrivacy *local = [LocalNetworkPrivacy new];
  [local checkAccessState:^(BOOL granted) {
      [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
