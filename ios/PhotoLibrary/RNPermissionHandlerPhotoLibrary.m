#import "RNPermissionHandlerPhotoLibrary.h"
#import <React/RCTUtils.h>

@import Photos;
@import PhotosUI;

@implementation RNPermissionHandlerPhotoLibrary

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSPhotoLibraryUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.PHOTO_LIBRARY";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  PHAuthorizationStatus status;

  if (@available(iOS 14.0, *)) {
    status = [PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite];
  } else {
    status = [PHPhotoLibrary authorizationStatus];
  }

  switch (status) {
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
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 14.0, *)) {
    [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelReadWrite handler:^(__unused PHAuthorizationStatus status) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  } else {
    [PHPhotoLibrary requestAuthorization:^(__unused PHAuthorizationStatus status) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  }
}

- (void)openPhotoPickerWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                           rejecter:(RCTPromiseRejectBlock _Nonnull)reject {
  if (@available(iOS 14.0, *)) {
    if ([PHPhotoLibrary authorizationStatusForAccessLevel:PHAccessLevelReadWrite] != PHAuthorizationStatusLimited) {
      return reject(@"cannot_open_limited_picker", @"Photo library permission isn't limited", nil);
    }

    UIViewController *viewController = RCTPresentedViewController();
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];

    if (@available(iOS 15, *)) {
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
  } else {
    reject(@"cannot_open_limited_picker", @"Only available on iOS 14 or higher", nil);
  }
}

@end
