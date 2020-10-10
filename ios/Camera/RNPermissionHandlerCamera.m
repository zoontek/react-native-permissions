#import "RNPermissionHandlerCamera.h"

@import AVFoundation;

@implementation RNPermissionHandlerCamera

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSCameraUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.CAMERA";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
    case AVAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case AVAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case AVAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case AVAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                           completionHandler:^(__unused BOOL granted) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
