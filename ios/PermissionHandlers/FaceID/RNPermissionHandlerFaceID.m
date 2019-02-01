#import "RNPermissionHandlerFaceID.h"

@import LocalAuthentication;

@implementation RNPermissionHandlerFaceID

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSFaceIDUsageDescription"];
}

- (void)handleError:(NSError *)error
       withResolver:(void (^)(RNPermissionStatus status))resolve
       withRejecter:(void (^)(NSError *error))reject {
  if (error.code == -6) {
    resolve(RNPermissionStatusDenied);
  } else {
    reject(error);
  }
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (^)(NSError *error))reject {
  if (@available(iOS 11.0, *)) {
    if (![RNPermissionsManager hasBeenRequestedOnce:self]) {
      return resolve(RNPermissionStatusNotDetermined);
    }

    LAContext *context = [LAContext new];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];

    if (error != nil) {
      return [self handleError:error withResolver:resolve withRejecter:reject];
    }
    if (context.biometryType != LABiometryTypeFaceID) {
      return resolve(RNPermissionStatusNotAvailable);
    }

    resolve(RNPermissionStatusAuthorized);
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  if (@available(iOS 11.0, *)) {
    LAContext *context = [LAContext new];
    NSError *error;
    [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];

    if (error != nil) {
      return [self handleError:error withResolver:resolve withRejecter:reject];
    }
    if (context.biometryType != LABiometryTypeFaceID) {
      return resolve(RNPermissionStatusNotAvailable);
    }
    if ([RNPermissionsManager hasBeenRequestedOnce:self]) {
      return resolve(RNPermissionStatusAuthorized);
    }

    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSFaceIDUsageDescription"] reply:^(BOOL success, NSError * _Nullable error) {
      if (error != nil) {
        [self handleError:error withResolver:resolve withRejecter:reject];
      } else {
        resolve(success ? RNPermissionStatusAuthorized : RNPermissionStatusDenied);
      }
    }];
  } else {
    resolve(RNPermissionStatusNotAvailable);
  }
}

@end
