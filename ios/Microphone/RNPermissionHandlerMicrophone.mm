#import "RNPermissionHandlerMicrophone.h"

#import <AVFoundation/AVFoundation.h>

@implementation RNPermissionHandlerMicrophone

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSMicrophoneUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.MICROPHONE";
}

- (RNPermissionStatus)currentStatus {
  if (@available(iOS 17.0, tvOS 17.0, *)) {
    switch ([[AVAudioApplication sharedInstance] recordPermission]) {
      case AVAudioApplicationRecordPermissionUndetermined:
        return RNPermissionStatusNotDetermined;
      case AVAudioApplicationRecordPermissionDenied:
        return RNPermissionStatusDenied;
      case AVAudioApplicationRecordPermissionGranted:
        return RNPermissionStatusAuthorized;
    }
  } else {
#if TARGET_OS_TV
    return RNPermissionStatusNotAvailable;
#else
    switch ([[AVAudioSession sharedInstance] recordPermission]) {
      case AVAudioSessionRecordPermissionUndetermined:
        return RNPermissionStatusNotDetermined;
      case AVAudioSessionRecordPermissionDenied:
        return RNPermissionStatusDenied;
      case AVAudioSessionRecordPermissionGranted:
        return RNPermissionStatusAuthorized;
    }
#endif
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 17.0, tvOS 17.0, *)) {
    [AVAudioApplication requestRecordPermissionWithCompletionHandler:^(__unused BOOL granted) {
      resolve([self currentStatus]);
    }];
  } else {
#if TARGET_OS_TV
    resolve([self currentStatus]);
#else
    [[AVAudioSession sharedInstance] requestRecordPermission:^(__unused BOOL granted) {
      resolve([self currentStatus]);
    }];
#endif
  }
}

@end
