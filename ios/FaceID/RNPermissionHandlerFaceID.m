#import "RNPermissionHandlerFaceID.h"

@import LocalAuthentication;
@import UIKit;

static NSString* SETTING_KEY = @"@RNPermissions:Requested";

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

  NSArray<NSString *> *requested = [[NSUserDefaults standardUserDefaults] arrayForKey:SETTING_KEY];
  NSString *handlerId = [[self class] handlerUniqueId];

  if (requested == nil || ![requested containsObject:handlerId]) {
    return resolve(RNPermissionStatusNotDetermined);
  }

  resolve(RNPermissionStatusAuthorized);
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
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
                                           selector:@selector(onApplicationDidBecomeActive:)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];

  [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
          localizedReason:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSFaceIDUsageDescription"]
                    reply:^(__unused BOOL success, __unused NSError * _Nullable error) {}];

  // Hack to invalidate FaceID verification immediately after being requested
  [self performSelector:@selector(invalidateContext) withObject:self afterDelay:0.05];
}

- (void)invalidateContext {
  [_laContext invalidate];
}

- (void)onApplicationDidBecomeActive:(__unused NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:nil];

  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString *handlerId = [[self class] handlerUniqueId];
  NSMutableArray *requested = [[userDefaults arrayForKey:SETTING_KEY] mutableCopy];

  if (requested == nil) {
    requested = [NSMutableArray new];
  }

  if (![requested containsObject:handlerId]) {
    [requested addObject:handlerId];
    [userDefaults setObject:requested forKey:SETTING_KEY];
    [userDefaults synchronize];
  }

  [self checkWithResolver:_resolve rejecter:_reject];
}

@end
