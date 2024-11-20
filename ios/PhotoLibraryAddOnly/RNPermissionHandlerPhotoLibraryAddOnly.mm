#import "RNPermissionHandlerPhotoLibraryAddOnly.h"

#import <Photos/Photos.h>

@implementation RNPermissionHandlerPhotoLibraryAddOnly

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSPhotoLibraryAddUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.PHOTO_LIBRARY_ADD_ONLY";
}

- (RNPermissionStatus)currentStatus {
  if (@available(iOS 14.0, tvOS 14.0, *)) {
    switch ([PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelAddOnly]) {
      case PHAuthorizationStatusNotDetermined:
        return RNPermissionStatusNotDetermined;
      case PHAuthorizationStatusRestricted:
        return RNPermissionStatusRestricted;
      case PHAuthorizationStatusDenied:
        return RNPermissionStatusDenied;
      case PHAuthorizationStatusLimited:
        return RNPermissionStatusLimited;
      case PHAuthorizationStatusAuthorized:
        return RNPermissionStatusAuthorized;
    }
  } else {
    return RNPermissionStatusNotAvailable;
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 14.0, tvOS 14.0, *)) {
    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(__unused PHAuthorizationStatus status) {
      resolve([self currentStatus]);
    }];
  } else {
    return resolve(RNPermissionStatusNotAvailable);
  }
}

@end
