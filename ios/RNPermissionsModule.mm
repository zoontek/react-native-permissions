#import "RNPermissionsModule.h"
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
#if __has_include("RNPermissionHandlerAppTrackingTransparency.h")
#import "RNPermissionHandlerAppTrackingTransparency.h"
#endif
#if __has_include("RNPermissionHandlerPhotoLibraryAddOnly.h")
#import "RNPermissionHandlerPhotoLibraryAddOnly.h"
#endif
#if __has_include("RNPermissionHandlerLocationAccuracy.h")
#import "RNPermissionHandlerLocationAccuracy.h"
#endif

@implementation RCTConvert(RNPermission)

RCT_ENUM_CONVERTER(RNPermission, (@{
#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
  [RNPermissionHandlerBluetoothPeripheral handlerUniqueId]: @(RNPermissionBluetoothPeripheral),
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
  [RNPermissionHandlerCalendars handlerUniqueId]: @(RNPermissionCalendars),
#endif
#if __has_include("RNPermissionHandlerCamera.h")
  [RNPermissionHandlerCamera handlerUniqueId]: @(RNPermissionCamera),
#endif
#if __has_include("RNPermissionHandlerContacts.h")
  [RNPermissionHandlerContacts handlerUniqueId]: @(RNPermissionContacts),
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
  [RNPermissionHandlerFaceID handlerUniqueId]: @(RNPermissionFaceID),
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
  [RNPermissionHandlerLocationAlways handlerUniqueId]: @(RNPermissionLocationAlways),
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
  [RNPermissionHandlerLocationWhenInUse handlerUniqueId]: @(RNPermissionLocationWhenInUse),
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
  [RNPermissionHandlerMediaLibrary handlerUniqueId]: @(RNPermissionMediaLibrary),
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
  [RNPermissionHandlerMicrophone handlerUniqueId]: @(RNPermissionMicrophone),
#endif
#if __has_include("RNPermissionHandlerMotion.h")
  [RNPermissionHandlerMotion handlerUniqueId]: @(RNPermissionMotion),
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  [RNPermissionHandlerPhotoLibrary handlerUniqueId]: @(RNPermissionPhotoLibrary),
#endif
#if __has_include("RNPermissionHandlerReminders.h")
  [RNPermissionHandlerReminders handlerUniqueId]: @(RNPermissionReminders),
#endif
#if __has_include("RNPermissionHandlerSiri.h")
  [RNPermissionHandlerSiri handlerUniqueId]: @(RNPermissionSiri),
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
  [RNPermissionHandlerSpeechRecognition handlerUniqueId]: @(RNPermissionSpeechRecognition),
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
  [RNPermissionHandlerStoreKit handlerUniqueId]: @(RNPermissionStoreKit),
#endif
#if __has_include("RNPermissionHandlerAppTrackingTransparency.h")
  [RNPermissionHandlerAppTrackingTransparency handlerUniqueId]: @(RNPermissionAppTrackingTransparency),
#endif
#if __has_include("RNPermissionHandlerPhotoLibraryAddOnly.h")
  [RNPermissionHandlerPhotoLibraryAddOnly handlerUniqueId]: @(RNPermissionPhotoLibraryAddOnly),
#endif
}), RNPermissionUnknown, integerValue);

@end

@interface RNPermissionsModule()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<RNPermissionHandler>> *_Nonnull handlers;

@end

@implementation RNPermissionsModule

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return YES;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
  NSMutableArray<NSString *> *available = [NSMutableArray new];

#if __has_include("RNPermissionHandlerBluetoothPeripheral.h")
  [available addObject:[RNPermissionHandlerBluetoothPeripheral handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
  [available addObject:[RNPermissionHandlerCalendars handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerCamera.h")
  [available addObject:[RNPermissionHandlerCamera handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerContacts.h")
  [available addObject:[RNPermissionHandlerContacts handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
  [available addObject:[RNPermissionHandlerFaceID handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
  [available addObject:[RNPermissionHandlerLocationAlways handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
  [available addObject:[RNPermissionHandlerLocationWhenInUse handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
  [available addObject:[RNPermissionHandlerMediaLibrary handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
  [available addObject:[RNPermissionHandlerMicrophone handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerMotion.h")
  [available addObject:[RNPermissionHandlerMotion handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerNotifications.h")
  [available addObject:[RNPermissionHandlerNotifications handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  [available addObject:[RNPermissionHandlerPhotoLibrary handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerReminders.h")
  [available addObject:[RNPermissionHandlerReminders handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerSiri.h")
  [available addObject:[RNPermissionHandlerSiri handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
  [available addObject:[RNPermissionHandlerSpeechRecognition handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
  [available addObject:[RNPermissionHandlerStoreKit handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerAppTrackingTransparency.h")
  [available addObject:[RNPermissionHandlerAppTrackingTransparency handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerPhotoLibraryAddOnly.h")
  [available addObject:[RNPermissionHandlerPhotoLibraryAddOnly handlerUniqueId]];
#endif
#if __has_include("RNPermissionHandlerLocationAccuracy.h")
  [available addObject:[RNPermissionHandlerLocationAccuracy handlerUniqueId]];
#endif

#if RCT_DEV
  if ([available count] == 0) {
    NSMutableString *message = [NSMutableString new];

    [message appendString:@"⚠  No permission handler detected.\n\n"];
    [message appendString:@"• Check that you added at least one permission handler in your package.json reactNativePermissionsIOS config.\n"];
    [message appendString:@"• Uninstall this app, reinstall your Pods, delete your Xcode DerivedData folder and rebuild it.\n"];

    RCTLogError(@"%@", message);
  }
#endif

  return @{ @"available": available };
}

- (void)checkUsageDescriptionKeys:(NSArray<NSString *> * _Nonnull)keys {
#if RCT_DEV
  for (NSString *key in keys) {
    if (![[NSBundle mainBundle] objectForInfoDictionaryKey:key]) {
      RCTLogError(@"Cannot check or request permission without the required \"%@\" entry in your app \"Info.plist\" file", key);
      return;
    }
  }
#endif
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
#if __has_include("RNPermissionHandlerAppTrackingTransparency.h")
    case RNPermissionAppTrackingTransparency:
      handler = [RNPermissionHandlerAppTrackingTransparency new];
      break;
#endif
#if __has_include("RNPermissionHandlerPhotoLibraryAddOnly.h")
    case RNPermissionPhotoLibraryAddOnly:
      handler = [RNPermissionHandlerPhotoLibraryAddOnly new];
      break;
#endif
    case RNPermissionUnknown:
      break; // RCTConvert prevents this case
  }

  [self checkUsageDescriptionKeys:[[handler class] usageDescriptionKeys]];
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
    case RNPermissionStatusLimited:
      return @"limited";
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

RCT_EXPORT_METHOD(openSettings:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  UIApplication *sharedApplication = [UIApplication sharedApplication];
  NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

  [sharedApplication openURL:url options:@{} completionHandler:^(BOOL success) {
    if (success) {
      resolve(@(true));
    } else {
      reject(@"cannot_open_settings", @"Cannot open application settings", nil);
    }
  }];
}

RCT_EXPORT_METHOD(check:
#ifdef RCT_NEW_ARCH_ENABLED
                  (NSString *)permission
#else
                  (RNPermission)permission
#endif
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
#ifdef RCT_NEW_ARCH_ENABLED
  id<RNPermissionHandler> handler = [self handlerForPermission:[RCTConvert RNPermission:permission]];
#else
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];
#endif

  NSString *lockId = [self lockHandler:handler];

  [handler checkWithResolver:^(RNPermissionStatus status) {
    resolve([self stringForStatus:status]);
    [self unlockHandler:lockId];
  } rejecter:^(NSError *error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  }];
}

RCT_EXPORT_METHOD(request:
#ifdef RCT_NEW_ARCH_ENABLED
                  (NSString *)permission
#else
                  (RNPermission)permission
#endif
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
#ifdef RCT_NEW_ARCH_ENABLED
  id<RNPermissionHandler> handler = [self handlerForPermission:[RCTConvert RNPermission:permission]];
#else
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];
#endif

  NSString *lockId = [self lockHandler:handler];

  [handler requestWithResolver:^(RNPermissionStatus status) {
    resolve([self stringForStatus:status]);
    [self unlockHandler:lockId];
  } rejecter:^(NSError *error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  }];
}

RCT_EXPORT_METHOD(checkNotifications:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
#if __has_include("RNPermissionHandlerNotifications.h")
  RNPermissionHandlerNotifications *handler = [RNPermissionHandlerNotifications new];
  NSString *lockId = [self lockHandler:(id<RNPermissionHandler>)handler];

  [handler checkWithResolver:^(RNPermissionStatus status, NSDictionary * _Nonnull settings) {
    resolve(@{ @"status": [self stringForStatus:status], @"settings": settings });
    [self unlockHandler:lockId];
  } rejecter:^(NSError * _Nonnull error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  }];
#else
  reject(@"notifications_pod_missing", @"Notifications permission pod is missing", nil);
#endif
}

RCT_EXPORT_METHOD(requestNotifications:(NSArray<NSString *> * _Nonnull)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
#if __has_include("RNPermissionHandlerNotifications.h")
  RNPermissionHandlerNotifications *handler = [RNPermissionHandlerNotifications new];
  NSString *lockId = [self lockHandler:(id<RNPermissionHandler>)handler];

  [handler requestWithResolver:^(RNPermissionStatus status, NSDictionary * _Nonnull settings) {
    resolve(@{ @"status": [self stringForStatus:status], @"settings": settings });
    [self unlockHandler:lockId];
  } rejecter:^(NSError * _Nonnull error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  } options:options];
#else
  reject(@"notifications_pod_missing", @"Notifications permission pod is missing", nil);
#endif
}

RCT_EXPORT_METHOD(openLimitedPhotoLibraryPicker:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  RNPermissionHandlerPhotoLibrary *handler = [RNPermissionHandlerPhotoLibrary new];
  [handler openLimitedPhotoLibraryPickerWithResolver:resolve rejecter:reject];
#else
  reject(@"photo_library_pod_missing", @"PhotoLibrary permission pod is missing", nil);
#endif
}

RCT_EXPORT_METHOD(checkLocationAccuracy:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
#if __has_include("RNPermissionHandlerLocationAccuracy.h")
  [self checkUsageDescriptionKeys:[RNPermissionHandlerLocationAccuracy usageDescriptionKeys]];

  RNPermissionHandlerLocationAccuracy *handler = [RNPermissionHandlerLocationAccuracy new];
  [handler checkWithResolver:resolve rejecter:reject];
#else
  reject(@"location_accuracy_pod_missing", @"LocationAccuracy permission pod is missing", nil);
#endif
}

RCT_EXPORT_METHOD(requestLocationAccuracy:(NSString * _Nonnull)purposeKey
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
#if __has_include("RNPermissionHandlerLocationAccuracy.h")
  [self checkUsageDescriptionKeys:[RNPermissionHandlerLocationAccuracy usageDescriptionKeys]];

  RNPermissionHandlerLocationAccuracy *handler = [RNPermissionHandlerLocationAccuracy new];
  [handler requestWithPurposeKey:purposeKey resolver:resolve rejecter:reject];
#else
  reject(@"location_accuracy_pod_missing", @"LocationAccuracy permission pod is missing", nil);
#endif
}

- (void)checkMultiplePermissions:(NSArray *)permissions
                         resolve:(RCTPromiseResolveBlock)resolve
                          reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:checkMultiplePermissions", @"checkMultiplePermissions is not supported on iOS", nil);
}

- (void)checkPermission:(NSString *)permission
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:checkPermission", @"checkPermission is not supported on iOS", nil);
}

- (void)requestMultiplePermissions:(NSArray *)permissions
                           resolve:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:requestMultiplePermissions", @"requestMultiplePermissions is not supported on iOS", nil);
}

- (void)requestPermission:(NSString *)permission
                  resolve:(RCTPromiseResolveBlock)resolve
                   reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:requestPermission", @"requestPermission is not supported on iOS", nil);
}

- (void)shouldShowRequestPermissionRationale:(NSString *)permission
                                     resolve:(RCTPromiseResolveBlock)resolve
                                      reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:shouldShowRequestPermissionRationale", @"shouldShowRequestPermissionRationale is not supported on iOS", nil);
}

#if RCT_NEW_ARCH_ENABLED

- (facebook::react::ModuleConstants<JS::NativePermissionsModule::Constants::Builder>)getConstants {
  return [self constantsToExport];
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativePermissionsModuleSpecJSI>(params);
}

#endif

@end
