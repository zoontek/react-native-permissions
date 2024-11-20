#import "RNPermissionHandlerCamera.h"

#import <AVFoundation/AVFoundation.h>

@implementation RNPermissionHandlerCamera

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSCameraUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CAMERA";
}

- (RNPermissionStatus)currentStatus {
  if (@available(iOS 7.0, tvOS 17.0, *)) {
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
      case AVAuthorizationStatusNotDetermined:
        return RNPermissionStatusNotDetermined;
      case AVAuthorizationStatusRestricted:
        return RNPermissionStatusRestricted;
      case AVAuthorizationStatusDenied:
        return RNPermissionStatusDenied;
      case AVAuthorizationStatusAuthorized:
        return RNPermissionStatusAuthorized;
    }
  } else {
    return RNPermissionStatusNotAvailable;
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 7.0, tvOS 17.0, *)) {
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(__unused BOOL granted) {
      resolve([self currentStatus]);
    }];
  } else {
    resolve([self currentStatus]);
  }
}

@end
