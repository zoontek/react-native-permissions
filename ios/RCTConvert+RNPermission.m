#import "RCTConvert+RNPermission.h"

@implementation RCTConvert(RNPermission)

RCT_ENUM_CONVERTER(RNPermission, (@{
#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
  @"BLUETOOTH_PERIPHERAL": @(RNPermissionBluetoothPeripheral),
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
  @"CALENDARS": @(RNPermissionCalendars),
#endif
#if __has_include("RNPermissionHandlerCamera.h")
  @"CAMERA": @(RNPermissionCamera),
#endif
#if __has_include("RNPermissionHandlerContacts.h")
  @"CONTACTS": @(RNPermissionContacts),
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
  @"FACE_ID": @(RNPermissionFaceID),
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
  @"LOCATION_ALWAYS": @(RNPermissionLocationAlways),
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
  @"LOCATION_WHEN_IN_USE": @(RNPermissionLocationWhenInUse),
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
  @"MEDIA_LIBRARY": @(RNPermissionMediaLibrary),
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
  @"MICROPHONE": @(RNPermissionMicrophone),
#endif
#if __has_include("RNPermissionHandlerMotion.h")
  @"MOTION": @(RNPermissionMotion),
#endif
#if __has_include("RNPermissionHandlerNotifications.h")
  @"NOTIFICATIONS": @(RNPermissionNotifications),
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  @"PHOTO_LIBRARY": @(RNPermissionPhotoLibrary),
#endif
#if __has_include("RNPermissionHandlerReminders.h")
  @"REMINDERS": @(RNPermissionReminders),
#endif
#if __has_include("RNPermissionHandlerSiri.h")
  @"SIRI": @(RNPermissionSiri),
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
  @"SPEECH_RECOGNITION": @(RNPermissionSpeechRecognition),
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
  @"STOREKIT": @(RNPermissionStoreKit),
#endif
}),
  RNPermissionUnknown, integerValue
)

@end
