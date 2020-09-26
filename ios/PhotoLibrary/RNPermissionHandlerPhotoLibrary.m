#import "RNPermissionHandlerPhotoLibrary.h"

@import Photos;

@implementation RNPermissionHandlerPhotoLibrary

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSPhotoLibraryUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.PHOTO_LIBRARY";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([PHPhotoLibrary authorizationStatus]) {
    case PHAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case PHAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case PHAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case PHAuthorizationStatusAuthorized:
#ifdef __IPHONE_14_0
    case PHAuthorizationStatusLimited: // TODO: Handle Limited status
#endif
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [PHPhotoLibrary requestAuthorization:^(__unused PHAuthorizationStatus status) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
