#import "RNPermissions.h"
#import <React/RCTLog.h>

#import "RNPermissionHandlerBluetoothPeripheral.h"
#import "RNPermissionHandlerCalendars.h"
#import "RNPermissionHandlerCamera.h"
#import "RNPermissionHandlerContacts.h"
#import "RNPermissionHandlerFaceID.h"
#import "RNPermissionHandlerLocationAlways.h"
#import "RNPermissionHandlerLocationWhenInUse.h"
#import "RNPermissionHandlerMediaLibrary.h"
#import "RNPermissionHandlerMicrophone.h"
#import "RNPermissionHandlerMotion.h"
#import "RNPermissionHandlerNotifications.h"
#import "RNPermissionHandlerPhotoLibrary.h"
#import "RNPermissionHandlerReminders.h"
#import "RNPermissionHandlerSiri.h"
#import "RNPermissionHandlerSpeechRecognition.h"
#import "RNPermissionHandlerStoreKit.h"

static NSString* SETTING_KEY = @"@RNPermissions:Requested";

@implementation RCTConvert(RNPermission)

RCT_ENUM_CONVERTER(RNPermission, (@{
  [RNPermissionHandlerBluetoothPeripheral handlerUniqueId]: @(RNPermissionBluetoothPeripheral),
  [RNPermissionHandlerCalendars handlerUniqueId]: @(RNPermissionCalendars),
  [RNPermissionHandlerCamera handlerUniqueId]: @(RNPermissionCamera),
  [RNPermissionHandlerContacts handlerUniqueId]: @(RNPermissionContacts),
  [RNPermissionHandlerFaceID handlerUniqueId]: @(RNPermissionFaceID),
  [RNPermissionHandlerLocationAlways handlerUniqueId]: @(RNPermissionLocationAlways),
  [RNPermissionHandlerLocationWhenInUse handlerUniqueId]: @(RNPermissionLocationWhenInUse),
  [RNPermissionHandlerMediaLibrary handlerUniqueId]: @(RNPermissionMediaLibrary),
  [RNPermissionHandlerMicrophone handlerUniqueId]: @(RNPermissionMicrophone),
  [RNPermissionHandlerMotion handlerUniqueId]: @(RNPermissionMotion),
  [RNPermissionHandlerPhotoLibrary handlerUniqueId]: @(RNPermissionPhotoLibrary),
  [RNPermissionHandlerReminders handlerUniqueId]: @(RNPermissionReminders),
  [RNPermissionHandlerSiri handlerUniqueId]: @(RNPermissionSiri),
  [RNPermissionHandlerSpeechRecognition handlerUniqueId]: @(RNPermissionSpeechRecognition),
  [RNPermissionHandlerStoreKit handlerUniqueId]: @(RNPermissionStoreKit),
}), RNPermissionUnknown, integerValue);

@end

@interface RNPermissions()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<RNPermissionHandler>> *_Nonnull handlers;

@end

@implementation RNPermissions

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (id<RNPermissionHandler> _Nullable)handlerForPermission:(RNPermission)permission {
  id<RNPermissionHandler> handler = nil;

  switch (permission) {
    case RNPermissionBluetoothPeripheral:
      handler = [RNPermissionHandlerBluetoothPeripheral new];
      break;
    case RNPermissionCalendars:
      handler = [RNPermissionHandlerCalendars new];
      break;
    case RNPermissionCamera:
      handler = [RNPermissionHandlerCamera new];
      break;
    case RNPermissionContacts:
      handler = [RNPermissionHandlerContacts new];
      break;
    case RNPermissionFaceID:
      handler = [RNPermissionHandlerFaceID new];
      break;
    case RNPermissionLocationAlways:
      handler = [RNPermissionHandlerLocationAlways new];
      break;
    case RNPermissionLocationWhenInUse:
      handler = [RNPermissionHandlerLocationWhenInUse new];
      break;
    case RNPermissionMediaLibrary:
      handler = [RNPermissionHandlerMediaLibrary new];
      break;
    case RNPermissionMicrophone:
      handler = [RNPermissionHandlerMicrophone new];
      break;
    case RNPermissionMotion:
      handler = [RNPermissionHandlerMotion new];
      break;
    case RNPermissionPhotoLibrary:
      handler = [RNPermissionHandlerPhotoLibrary new];
      break;
    case RNPermissionReminders:
      handler = [RNPermissionHandlerReminders new];
      break;
    case RNPermissionSiri:
      handler = [RNPermissionHandlerSiri new];
      break;
    case RNPermissionSpeechRecognition:
      handler = [RNPermissionHandlerSpeechRecognition new];
      break;
    case RNPermissionStoreKit:
      handler = [RNPermissionHandlerStoreKit new];
      break;
    case RNPermissionUnknown:
      break; // RCTConvert prevents this case
  }

#if RCT_DEV
  for (NSString *key in [[handler class] usageDescriptionKeys]) {
    if (![[NSBundle mainBundle] objectForInfoDictionaryKey:key]) {
      RCTLogError(@"Cannot check or request permission without the required \"%@\" entry in your app \"Info.plist\" file", key);
      return nil;
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
      return @"blocked";
    case RNPermissionStatusAuthorized:
      return @"granted";
  }
}

- (NSString *)lockHandler:(id<RNPermissionHandler>)handler {
  if (_handlers == nil) {
    _handlers = [NSMutableDictionary new];
  }

  NSString *lockId = [[NSUUID UUID] UUIDString];
  [_handlers setObject:handler forKey:lockId];

  return lockId;
}

- (void)unlockHandler:(NSString * _Nonnull)lockId {
  if (_handlers != nil) {
    [self.handlers removeObjectForKey:lockId];
  }
}

+ (bool)isFlaggedAsRequested:(NSString * _Nonnull)handlerId {
  NSArray<NSString *> *requested = [[NSUserDefaults standardUserDefaults] arrayForKey:SETTING_KEY];
  return requested == nil ? false : [requested containsObject:handlerId];
}

+ (void)flagAsRequested:(NSString * _Nonnull)handlerId {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray *requested = [[userDefaults arrayForKey:SETTING_KEY] mutableCopy];

  if (requested == nil) {
    requested = [NSMutableArray new];
  }

  if (![requested containsObject:handlerId]) {
    [requested addObject:handlerId];
    [userDefaults setObject:requested forKey:SETTING_KEY];
    [userDefaults synchronize];
  }
}

RCT_REMAP_METHOD(openSettings,
                 openSettingsWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  UIApplication *sharedApplication = [UIApplication sharedApplication];
  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

  if (@available(iOS 10.0, *)) {
    [sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
      if (success) {
        resolve(@(true));
      } else {
        reject(@"cannot_open_settings", @"Cannot open application settings", nil);
      }
    }];
  } else {
    [sharedApplication openURL:url];
    resolve(@(true));
  }
}

RCT_REMAP_METHOD(check,
                 checkWithPermission:(RNPermission)permission
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];
  NSString *lockId = [self lockHandler:handler];

  [handler checkWithResolver:^(RNPermissionStatus status) {
    NSString *strStatus = [self stringForStatus:status];
    NSLog(@"[react-native-permissions] %@ permission checked: %@", [[handler class] handlerUniqueId], strStatus);

    resolve(strStatus);
    [self unlockHandler:lockId];
  } rejecter:^(NSError *error) {
    NSLog(@"[react-native-permissions] %@ permission failed: %@", [[handler class] handlerUniqueId], error.localizedDescription);

    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  }];
}

RCT_REMAP_METHOD(request,
                 requestWithPermission:(RNPermission)permission
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];
  NSString *lockId = [self lockHandler:handler];

  [handler requestWithResolver:^(RNPermissionStatus status) {
    NSString *strStatus = [self stringForStatus:status];
    NSLog(@"[react-native-permissions] %@ permission checked: %@", [[handler class] handlerUniqueId], strStatus);

    resolve(strStatus);
    [self unlockHandler:lockId];
  } rejecter:^(NSError *error) {
    NSLog(@"[react-native-permissions] %@ permission failed: %@", [[handler class] handlerUniqueId], error.localizedDescription);

    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  }];
}

RCT_REMAP_METHOD(checkNotifications,
                 checkNotificationsWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  RNPermissionHandlerNotifications *handler = [RNPermissionHandlerNotifications new];
  NSString *lockId = [self lockHandler:(id<RNPermissionHandler>)handler];

  [handler checkWithResolver:^(RNPermissionStatus status, NSDictionary * _Nonnull settings) {
    NSString *strStatus = [self stringForStatus:status];
    NSLog(@"[react-native-permissions] %@ permission checked: %@", [[handler class] handlerUniqueId], strStatus);

    resolve(@{ @"status": strStatus, @"settings": settings });
    [self unlockHandler:lockId];
  } rejecter:^(NSError * _Nonnull error) {
    NSLog(@"[react-native-permissions] %@ permission failed: %@", [[handler class] handlerUniqueId], error.localizedDescription);

    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  }];
}

RCT_REMAP_METHOD(requestNotifications,
                 requestNotificationsWithOptions:(NSArray<NSString *> * _Nonnull)options
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  RNPermissionHandlerNotifications *handler = [RNPermissionHandlerNotifications new];
  NSString *lockId = [self lockHandler:(id<RNPermissionHandler>)handler];

  [handler requestWithResolver:^(RNPermissionStatus status, NSDictionary * _Nonnull settings) {
    NSString *strStatus = [self stringForStatus:status];
    NSLog(@"[react-native-permissions] %@ permission checked: %@", [[handler class] handlerUniqueId], strStatus);

    resolve(@{ @"status": strStatus, @"settings": settings });
    [self unlockHandler:lockId];
  } rejecter:^(NSError * _Nonnull error) {
    NSLog(@"[react-native-permissions] %@ permission failed: %@", [[handler class] handlerUniqueId], error.localizedDescription);

    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  } options:options];
}

@end
