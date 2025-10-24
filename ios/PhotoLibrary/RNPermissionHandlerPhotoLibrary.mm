#import "RNPermissionHandlerPhotoLibrary.h"
#import <React/RCTUtils.h>

#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>

@implementation RNPermissionHandlerPhotoLibrary

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSPhotoLibraryUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.PHOTO_LIBRARY";
}

- (RNPermissionStatus)currentStatus {
  switch ([PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite]) {
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
  [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(__unused PHAuthorizationStatus status) {
    resolve([self currentStatus]);
  }];
}

- (void)openPhotoPickerWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                           rejecter:(RCTPromiseRejectBlock _Nonnull)reject {
  if ([PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite] != PHAuthorizationStatusLimited) {
    return reject(@"cannot_open_limited_picker", @"Photo library permission isn't limited", nil);
  }

#if TARGET_OS_TV
  reject(@"cannot_open_limited_picker", @"Only available on iOS 14 or higher", nil);
#else
  UIViewController *viewController = RCTPresentedViewController();
  PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];

  [photoLibrary presentLimitedLibraryPickerFromViewController:viewController
                                            completionHandler:^(__unused NSArray<NSString *> * _Nonnull assets) {
    resolve(@(true));
  }];
#endif
}

@end
