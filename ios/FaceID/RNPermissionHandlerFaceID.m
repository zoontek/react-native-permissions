#import "RNPermissionHandlerFaceID.h"

@import LocalAuthentication;
@import UIKit;

@interface RNPermissionHandlerFaceID()

@property (nonatomic, strong) LAContext *laContext;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerFaceID

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSFaceIDUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.FACE_ID";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 11.0.1, *)) {
    LAContext *context = [LAContext new];
    NSError *error;

    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    bool hasFaceID = context.biometryType == LABiometryTypeFaceID;

    if (!hasFaceID) {
      return resolve(RNPermissionStatusNotAvailable);
    }

    if (error != nil) {
      if (error.code == LAErrorBiometryNotAvailable && hasFaceID)
        return resolve(RNPermissionStatusDenied);
      else
        return resolve(RNPermissionStatusNotAvailable);
    }

    if (![RNPermissions isFlaggedAsRequested:[[self class] handlerUniqueId]]) {
      return resolve(RNPermissionStatusNotDetermined);
    }

    resolve(RNPermissionStatusAuthorized);
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
  if (@available(iOS 11.0.1, *)) {
    LAContext *context = [LAContext new];
    NSError *error;

    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    bool hasFaceID = context.biometryType == LABiometryTypeFaceID;

    if (!hasFaceID) {
      return resolve(RNPermissionStatusNotAvailable);
    }

    if (error != nil) {
      if (error.code == LAErrorBiometryNotAvailable && hasFaceID)
        return resolve(RNPermissionStatusDenied);
      else
        return resolve(RNPermissionStatusNotAvailable);
    }

    _resolve = resolve;
    _reject = reject;
    _laContext = context;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(UIApplicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSFaceIDUsageDescription"]
                      reply:^(__unused BOOL success, __unused NSError * _Nullable error) {}];

    // Hack to invalidate FaceID verification immediately after being requested
    [self performSelector:@selector(invalidateContext) withObject:self afterDelay:0.05];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)invalidateContext {
  [_laContext invalidate];
}

- (void)UIApplicationDidBecomeActiveNotification:(__unused NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:nil];

  [RNPermissions flagAsRequested:[[self class] handlerUniqueId]];
  [self checkWithResolver:_resolve rejecter:_reject];
}

@end
