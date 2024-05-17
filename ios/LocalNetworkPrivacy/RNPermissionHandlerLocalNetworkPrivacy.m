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
  if (![RNPermissionsHelper isFlaggedAsRequested:[[self class] handlerUniqueId]]) {
    return resolve(RNPermissionStatusNotDetermined);
  }

  [self requestWithResolver:resolve rejecter:reject];
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [RNPermissionsHelper flagAsRequested:[[self class] handlerUniqueId]];

  LocalNetworkPrivacy *local = [LocalNetworkPrivacy new];
  [local checkAccessState:^(BOOL granted) {
      resolve(granted ? RNPermissionStatusAuthorized : RNPermissionStatusDenied);
  }];
}

@end
