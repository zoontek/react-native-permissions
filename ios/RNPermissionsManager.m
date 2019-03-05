#import "RNPermissionsManager.h"
#import "RCTConvert+RNPermission.h"

#import <React/RCTLog.h>

#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
#import "RNPermissionHandlerBluetoothPeripheral.h"
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
#import "RNPermissionHandlerCalendars.h"
#endif
#if __has_include("RNPermissionHandlerCamera.h")
#import "RNPermissionHandlerCamera.h"
#endif
#if __has_include("RNPermissionHandlerContacts.h")
#import "RNPermissionHandlerContacts.h"
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
#import "RNPermissionHandlerFaceID.h"
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
#import "RNPermissionHandlerLocationAlways.h"
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
#import "RNPermissionHandlerLocationWhenInUse.h"
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
#import "RNPermissionHandlerMediaLibrary.h"
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
#import "RNPermissionHandlerMicrophone.h"
#endif
#if __has_include("RNPermissionHandlerMotion.h")
#import "RNPermissionHandlerMotion.h"
#endif
#if __has_include("RNPermissionHandlerNotifications.h")
#import "RNPermissionHandlerNotifications.h"
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
#import "RNPermissionHandlerPhotoLibrary.h"
#endif
#if __has_include("RNPermissionHandlerReminders.h")
#import "RNPermissionHandlerReminders.h"
#endif
#if __has_include("RNPermissionHandlerSiri.h")
#import "RNPermissionHandlerSiri.h"
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
#import "RNPermissionHandlerSpeechRecognition.h"
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
#import "RNPermissionHandlerStoreKit.h"
#endif

static NSString* requestedKey = @"@RNPermissions:requested";

@implementation RNPermissionsManager

RCT_EXPORT_MODULE(RNPermissions);

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (id<RNPermissionHandler> _Nullable)handlerForPermission:(RNPermission)permission {
  id<RNPermissionHandler> handler = nil;

  switch (permission) {
#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
    case RNPermissionBluetoothPeripheral:
      handler = [RNPermissionHandlerBluetoothPeripheral new];
      break;
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
    case RNPermissionCalendars:
      handler = [RNPermissionHandlerCalendars new];
      break;
#endif
#if __has_include("RNPermissionHandlerCamera.h")
    case RNPermissionCamera:
      handler = [RNPermissionHandlerCamera new];
      break;
#endif
#if __has_include("RNPermissionHandlerContacts.h")
    case RNPermissionContacts:
      handler = [RNPermissionHandlerContacts new];
      break;
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
    case RNPermissionFaceID:
      handler = [RNPermissionHandlerFaceID new];
      break;
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
    case RNPermissionLocationAlways:
      handler = [RNPermissionHandlerLocationAlways new];
      break;
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
    case RNPermissionLocationWhenInUse:
      handler = [RNPermissionHandlerLocationWhenInUse new];
      break;
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
    case RNPermissionMediaLibrary:
      handler = [RNPermissionHandlerMediaLibrary new];
      break;
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
    case RNPermissionMicrophone:
      handler = [RNPermissionHandlerMicrophone new];
      break;
#endif
#if __has_include("RNPermissionHandlerMotion.h")
    case RNPermissionMotion:
      handler = [RNPermissionHandlerMotion new];
      break;
#endif
#if __has_include("RNPermissionHandlerNotifications.h")
    case RNPermissionNotifications:
      handler = [RNPermissionHandlerNotifications new];
      break;
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
    case RNPermissionPhotoLibrary:
      handler = [RNPermissionHandlerPhotoLibrary new];
      break;
#endif
#if __has_include("RNPermissionHandlerReminders.h")
    case RNPermissionReminders:
      handler = [RNPermissionHandlerReminders new];
      break;
#endif
#if __has_include("RNPermissionHandlerSiri.h")
    case RNPermissionSiri:
      handler = [RNPermissionHandlerSiri new];
      break;
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
    case RNPermissionSpeechRecognition:
      handler = [RNPermissionHandlerSpeechRecognition new];
      break;
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
    case RNPermissionStoreKit:
      handler = [RNPermissionHandlerStoreKit new];
      break;
#endif
    case RNPermissionUnknown:
      break; // RCTConvert prevents this case
  }

#if RCT_DEV
  if (handler != nil && [[handler class] respondsToSelector:@selector(usageDescriptionKeys)]) {
    NSArray<NSString *> *usageDescriptionKeys = [[handler class] usageDescriptionKeys];

    for (NSString *key in usageDescriptionKeys) {
      if (![[NSBundle mainBundle] objectForInfoDictionaryKey:key]) {
        RCTLogError(@"Cannot check or request permission without the required \"%@\" entry in your app \"Info.plist\" file.", key);
        return nil;
      }
    }
  }
#endif

  return handler;
}

- (NSString *)stringForStatus:(RNPermissionStatus)status {
  switch (status) {
    case RNPermissionStatusNotAvailable:
    case RNPermissionStatusRestricted:
      return @"unavailable";
    case RNPermissionStatusNotDetermined:
      return @"denied";
    case RNPermissionStatusDenied:
      return @"never_ask_again";
    case RNPermissionStatusAuthorized:
      return @"granted";
  }
}

+ (bool)hasBackgroundModeEnabled:(NSString *)mode {
  NSArray *modes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
  return [modes isKindOfClass:[NSArray class]] && [modes containsObject:mode];
}

+ (void)logErrorMessage:(NSString *)message {
  RCTLogError(@"%@", message);
}

+ (bool)hasBeenRequestedOnce:(id<RNPermissionHandler>)handler {
  NSArray *requested = [[NSUserDefaults standardUserDefaults] arrayForKey:requestedKey];
  return [requested containsObject:NSStringFromClass([handler class])];
}

RCT_REMAP_METHOD(openSettings,
                 openSettingsWithResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject) {
  UIApplication *sharedApplication = [UIApplication sharedApplication];
  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

  if ([sharedApplication canOpenURL:url]) {
    [sharedApplication openURL:url];
    resolve(@(true));
  } else {
    reject(@"cannot_open_settings", @"Cannot open application settings.", nil);
  }
}

RCT_REMAP_METHOD(check,
                 checkWithPermission:(RNPermission)permission
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];

  [handler checkWithResolver:^(RNPermissionStatus status) {
    resolve([self stringForStatus:status]);
  } withRejecter:^(NSError *error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
  }];
}

RCT_REMAP_METHOD(request,
                 requestWithPermission:(RNPermission)permission
                 withOptions:(NSDictionary * _Nullable)options
                 withResolver:(RCTPromiseResolveBlock)resolve
                 withRejecter:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];

  [handler requestWithOptions:options withResolver:^(RNPermissionStatus status) {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *handlerClassName = NSStringFromClass([handler class]);
    NSMutableArray *requested = [[userDefaults arrayForKey:requestedKey] mutableCopy];

    if (requested == nil) {
      requested = [NSMutableArray new];
    }

    if (![requested containsObject:handlerClassName]) {
      [requested addObject:handlerClassName];
      [userDefaults setObject:requested forKey:requestedKey];
      [userDefaults synchronize];
    }

    resolve([self stringForStatus:status]);
  } withRejecter:^(NSError *error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
  }];
}

@end
