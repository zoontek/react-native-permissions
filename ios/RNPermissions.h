#import <React/RCTBridgeModule.h>
#import <React/RCTConvert.h>

typedef NS_ENUM(NSInteger, RNPermission) {
  RNPermissionUnknown = 0,
#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
  RNPermissionBluetoothPeripheral = 1,
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
  RNPermissionCalendars = 2,
#endif
#if __has_include("RNPermissionHandlerCamera.h")
  RNPermissionCamera = 3,
#endif
#if __has_include("RNPermissionHandlerContacts.h")
  RNPermissionContacts = 4,
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
  RNPermissionFaceID = 5,
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
  RNPermissionLocationAlways = 6,
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
  RNPermissionLocationWhenInUse = 7,
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
  RNPermissionMediaLibrary = 8,
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
  RNPermissionMicrophone = 9,
#endif
#if __has_include("RNPermissionHandlerMotion.h")
  RNPermissionMotion = 10,
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  RNPermissionPhotoLibrary = 11,
#endif
#if __has_include("RNPermissionHandlerReminders.h")
  RNPermissionReminders = 12,
#endif
#if __has_include("RNPermissionHandlerSiri.h")
  RNPermissionSiri = 13,
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
  RNPermissionSpeechRecognition = 14,
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
  RNPermissionStoreKit = 15,
#endif
#if __has_include("RNPermissionHandlerAppTrackingTransparency.h")
  RNPermissionAppTrackingTransparency = 16,
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

@end
