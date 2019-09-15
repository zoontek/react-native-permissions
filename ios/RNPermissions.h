#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>

typedef NS_ENUM(NSInteger, RNPermission) {
  RNPermissionUnknown = 0,
#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
  RNPermissionBluetoothPeripheral,
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
  RNPermissionCalendars,
#endif
#if __has_include("RNPermissionHandlerCamera.h")
  RNPermissionCamera,
#endif
#if __has_include("RNPermissionHandlerContacts.h")
  RNPermissionContacts,
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
  RNPermissionFaceID,
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
  RNPermissionLocationAlways,
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
  RNPermissionLocationWhenInUse,
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
  RNPermissionMediaLibrary,
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
  RNPermissionMicrophone,
#endif
#if __has_include("RNPermissionHandlerMotion.h")
  RNPermissionMotion,
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  RNPermissionPhotoLibrary,
#endif
#if __has_include("RNPermissionHandlerReminders.h")
  RNPermissionReminders,
#endif
#if __has_include("RNPermissionHandlerSiri.h")
  RNPermissionSiri,
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
  RNPermissionSpeechRecognition,
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
  RNPermissionStoreKit,
#endif
};

@interface RCTConvert (RNPermission)
@end

typedef enum {
  RNPermissionStatusNotAvailable = 0,
  RNPermissionStatusNotDetermined = 1,
  RNPermissionStatusRestricted = 2,
  RNPermissionStatusDenied = 3,
  RNPermissionStatusAuthorized = 4,
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

@interface RNPermissions : NSObject <RCTBridgeModule>

+ (bool)isFlaggedAsRequested:(NSString * _Nonnull)handlerId;

+ (void)flagAsRequested:(NSString * _Nonnull)handlerId;

+ (bool)isBackgroundModeEnabled:(NSString * _Nonnull)mode;

@end
