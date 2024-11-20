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
  PHAuthorizationStatus status;

  if (@available(iOS 14.0, tvOS 14.0, *)) {
    status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
  } else {
    status = [PHPhotoLibrary authorizationStatus];
  }

  switch (status) {
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
  if (@available(iOS 14.0, tvOS 14.0, *)) {
    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(__unused PHAuthorizationStatus status) {
      resolve([self currentStatus]);
    }];
  } else {
    [PHPhotoLibrary requestAuthorization:^(__unused PHAuthorizationStatus status) {
      resolve([self currentStatus]);
    }];
  }
}

- (void)openPhotoPickerWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                           rejecter:(RCTPromiseRejectBlock _Nonnull)reject {
  if (@available(iOS 14.0, tvOS 14.0, *)) {
    if ([PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite] != PHAuthorizationStatusLimited) {
      return reject(@"cannot_open_limited_picker", @"Photo library permission isn't limited", nil);
    }

#if TARGET_OS_TV
    reject(@"cannot_open_limited_picker", @"Only available on iOS 14 or higher", nil);
#else
    UIViewController *viewController = RCTPresentedViewController();
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];

    if (@available(iOS 15.0, *)) {
      [photoLibrary presentLimitedLibraryPickerFromViewController:viewController
                                                completionHandler:^(__unused NSArray<NSString *> * _Nonnull assets) {
        resolve(@(true));
      }];
    } else {
      __block bool pickerVisible = false;
      [photoLibrary presentLimitedLibraryPickerFromViewController:viewController];

      [NSTimer scheduledTimerWithTimeInterval:0.1
                                      repeats:true
                                        block:^(NSTimer * _Nonnull timer) {
        if ([RCTPresentedViewController() class] == [PHPickerViewController class]) {
          pickerVisible = true;
        } else if (pickerVisible) {
          [timer invalidate];
          resolve(@(true));
        }
      }];
    }
#endif
  } else {
    reject(@"cannot_open_limited_picker", @"Only available on iOS 14 or higher", nil);
  }
}

@end
