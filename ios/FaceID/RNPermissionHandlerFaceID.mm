#import "RNPermissionHandlerFaceID.h"

#import <LocalAuthentication/LocalAuthentication.h>

@interface RNPermissionHandlerFaceID()

#if !TARGET_OS_TV
@property (nonatomic, strong) LAContext *laContext;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);
#endif

@end

@implementation RNPermissionHandlerFaceID

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[@"NSFaceIDUsageDescription"];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.FACE_ID";
}

- (RNPermissionStatus)currentStatus {
#if TARGET_OS_TV
  return RNPermissionStatusNotAvailable;
#else
  LAContext *context = [LAContext new];
  NSError *error;

  [context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
  bool hasFaceID = context.biometryType == LABiometryTypeFaceID;

  if (!hasFaceID) {
    return RNPermissionStatusNotAvailable;
  }

  if (error != nil) {
    if (error.code == LAErrorBiometryNotAvailable && hasFaceID)
      return RNPermissionStatusDenied;
    else
      return RNPermissionStatusNotAvailable;
  }

  if (![RNPermissions isFlaggedAsRequested:[[self class] handlerUniqueId]]) {
    return RNPermissionStatusNotDetermined;
  }

  return RNPermissionStatusAuthorized;
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_TV
  resolve(RNPermissionStatusNotAvailable);
#else
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
#endif
}

- (void)invalidateContext {
#if !TARGET_OS_TV
  [_laContext invalidate];
#endif
}

- (void)onApplicationDidBecomeActive:(__unused NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UIApplicationDidBecomeActiveNotification
                                                object:nil];

  [RNPermissions flagAsRequested:[[self class] handlerUniqueId]];

#if !TARGET_OS_TV
  _resolve([self currentStatus]);
#endif
}

@end
