#import "RNPermissionHandlerMicrophone.h"

#import <AVFoundation/AVFoundation.h>

@implementation RNPermissionHandlerMicrophone

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSMicrophoneUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.MICROPHONE";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 17.0, *)) {
    switch ([[AVAudioApplication sharedInstance] recordPermission]) {
      case AVAudioApplicationRecordPermissionUndetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case AVAudioApplicationRecordPermissionDenied:
        return resolve(RNPermissionStatusDenied);
      case AVAudioApplicationRecordPermissionGranted:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    switch ([[AVAudioSession sharedInstance] recordPermission]) {
      case AVAudioSessionRecordPermissionUndetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case AVAudioSessionRecordPermissionDenied:
        return resolve(RNPermissionStatusDenied);
      case AVAudioSessionRecordPermissionGranted:
        return resolve(RNPermissionStatusAuthorized);
    }
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 17.0, *)) {
    [AVAudioApplication requestRecordPermissionWithCompletionHandler:^(__unused BOOL granted) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  } else {
    [[AVAudioSession sharedInstance] requestRecordPermission:^(__unused BOOL granted) {
      [self checkWithResolver:resolve rejecter:reject];
    }];
  }
}

@end
