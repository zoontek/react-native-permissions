#import <React/RCTBridgeModule.h>

typedef enum {
  RNPermissionStatusNotAvailable = 0,
  RNPermissionStatusNotDetermined = 1,
  RNPermissionStatusRestricted = 2,
  RNPermissionStatusDenied = 3,
  RNPermissionStatusAuthorized = 4,
} RNPermissionStatus;

@protocol RNPermissionHandler <NSObject>

@optional

+ (NSArray<NSString *> *)usageDescriptionKeys;

@required

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (^)(NSError *error))reject;

- (void)requestWithOptions:(NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject;

@end

@interface RNPermissionsManager : NSObject <RCTBridgeModule>

+ (bool)hasBackgroundModeEnabled:(NSString *)mode;

+ (void)logErrorMessage:(NSString *)message;

+ (bool)hasBeenRequestedOnce:(id<RNPermissionHandler>)handler;

@end
