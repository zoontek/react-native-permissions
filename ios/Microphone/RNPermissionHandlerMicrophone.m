#import "RNPermissionHandlerMicrophone.h"

@import AVFoundation;

@implementation RNPermissionHandlerMicrophone

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSMicrophoneUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.MICROPHONE";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([[AVAudioSession sharedInstance] recordPermission]) {
    case AVAudioSessionRecordPermissionUndetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case AVAudioSessionRecordPermissionDenied:
      return resolve(RNPermissionStatusDenied);
    case AVAudioSessionRecordPermissionGranted:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [[AVAudioSession sharedInstance] requestRecordPermission:^(__unused BOOL granted) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
