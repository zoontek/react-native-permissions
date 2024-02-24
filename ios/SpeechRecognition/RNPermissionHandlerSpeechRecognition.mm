#import "RNPermissionHandlerSpeechRecognition.h"

#import <Speech/Speech.h>

@implementation RNPermissionHandlerSpeechRecognition

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSSpeechRecognitionUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.SPEECH_RECOGNITION";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
  switch ([SFSpeechRecognizer authorizationStatus]) {
    case SFSpeechRecognizerAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case SFSpeechRecognizerAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case SFSpeechRecognizerAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case SFSpeechRecognizerAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  [SFSpeechRecognizer requestAuthorization:^(__unused SFSpeechRecognizerAuthorizationStatus status) {
    [self checkWithResolver:resolve rejecter:reject];
  }];
}

@end
