#import "RNPermissionHandlerMediaLibrary.h"

@import MediaPlayer;

@implementation RNPermissionHandlerMediaLibrary

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSAppleMusicUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.MEDIA_LIBRARY";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_SIMULATOR || TARGET_OS_TV
  resolve(RNPermissionStatusNotAvailable);
#else
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
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_SIMULATOR || TARGET_OS_TV
  resolve(RNPermissionStatusNotAvailable);
#else
  [MPMediaLibrary requestAuthorization:^(__unused MPMediaLibraryAuthorizationStatus status) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
#endif
}

@end
