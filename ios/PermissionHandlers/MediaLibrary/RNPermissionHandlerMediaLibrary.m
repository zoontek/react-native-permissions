#import "RNPermissionHandlerMediaLibrary.h"

@import MediaPlayer;

@implementation RNPermissionHandlerMediaLibrary

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSAppleMusicUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
  if (@available(iOS 9.3, *)) {
    switch ([MPMediaLibrary authorizationStatus]) {
      case MPMediaLibraryAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case MPMediaLibraryAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case MPMediaLibraryAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case MPMediaLibraryAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  if (@available(iOS 9.3, *)) {
    [MPMediaLibrary requestAuthorization:^(__unused MPMediaLibraryAuthorizationStatus status) {
      [self checkWithResolver:resolve withRejecter:reject];
    }];
  } else {
    resolve(RNPermissionStatusAuthorized);
  }
}

@end
