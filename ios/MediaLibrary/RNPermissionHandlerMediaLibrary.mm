#import "RNPermissionHandlerMediaLibrary.h"

#import <MediaPlayer/MediaPlayer.h>

@implementation RNPermissionHandlerMediaLibrary

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSAppleMusicUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.MEDIA_LIBRARY";
}

- (RNPermissionStatus)currentStatus {
#if TARGET_OS_TV
  return RNPermissionStatusNotAvailable;
#else
  switch ([MPMediaLibrary authorizationStatus]) {
    case MPMediaLibraryAuthorizationStatusNotDetermined:
      return RNPermissionStatusNotDetermined;
    case MPMediaLibraryAuthorizationStatusRestricted:
      return RNPermissionStatusRestricted;
    case MPMediaLibraryAuthorizationStatusDenied:
      return RNPermissionStatusDenied;
    case MPMediaLibraryAuthorizationStatusAuthorized:
      return RNPermissionStatusAuthorized;
  }
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_TV
  resolve(RNPermissionStatusNotAvailable);
#else
  [MPMediaLibrary requestAuthorization:^(__unused MPMediaLibraryAuthorizationStatus status) {
    resolve([self currentStatus]);
  }];
#endif
}

@end
