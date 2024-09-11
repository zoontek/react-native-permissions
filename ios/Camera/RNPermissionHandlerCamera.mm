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
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                           completionHandler:^(__unused BOOL granted) {
    resolve([self currentStatus]);
  }];
}

@end
