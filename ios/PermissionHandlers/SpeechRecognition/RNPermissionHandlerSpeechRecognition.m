#import "RNPermissionHandlerSpeechRecognition.h"

@import Speech;

@implementation RNPermissionHandlerSpeechRecognition

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSSpeechRecognitionUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
  if (@available(iOS 10.0, *)) {
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
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  if (@available(iOS 10.0, *)) {
    [SFSpeechRecognizer requestAuthorization:^(__unused SFSpeechRecognizerAuthorizationStatus status) {
      [self checkWithResolver:resolve withRejecter:reject];
    }];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

@end
