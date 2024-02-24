#import "RNPermissionHandlerPhotoLibraryAddOnly.h"

#import <Photos/Photos.h>

@implementation RNPermissionHandlerPhotoLibraryAddOnly

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSPhotoLibraryAddUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.PHOTO_LIBRARY_ADD_ONLY";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 14.0, *)) {
    switch ([PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly]) {
      case PHAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case PHAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case PHAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case PHAuthorizationStatusLimited:
        return resolve(RNPermissionStatusLimited);
      case PHAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    return resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 14.0, *)) {
    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(__unused PHAuthorizationStatus status) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  } else {
    return resolve(RNPermissionStatusNotAvailable);
  }
}

@end
