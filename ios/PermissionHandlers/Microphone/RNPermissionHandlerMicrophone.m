#import "RNPermissionHandlerMicrophone.h"

@import AVFoundation;

@implementation RNPermissionHandlerMicrophone

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSMicrophoneUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
  switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio]) {
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

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(__unused BOOL granted) {
    [self checkWithResolver:resolve withRejecter:reject];
  }];
}

@end
