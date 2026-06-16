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
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(__unused PHAuthorizationStatus status) {
    resolve([self currentStatus]);
  }];
}

@end
