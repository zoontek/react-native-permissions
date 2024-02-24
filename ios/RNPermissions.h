#ifdef RCT_NEW_ARCH_ENABLED
#import <RNPermissionsSpec/RNPermissionsSpec.h>
#else
#import <React/RCTBridge.h>
#endif

typedef enum {
  RNPermissionStatusNotAvailable = 0,
  RNPermissionStatusNotDetermined = 1,
  RNPermissionStatusRestricted = 2,
  RNPermissionStatusDenied = 3,
  RNPermissionStatusAuthorized = 4,
  RNPermissionStatusLimited = 5,
} RNPermissionStatus;

@protocol RNPermissionHandler <NSObject>

@required

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys;

+ (NSString * _Nonnull)handlerUniqueId;

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus status))resolve
                 rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject;

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus status))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject;

@end

#ifdef RCT_NEW_ARCH_ENABLED
@interface RNPermissions : NSObject<NativeRNPermissionsSpec>
#else
@interface RNPermissions : NSObject<RCTBridgeModule>
#endif

@end
