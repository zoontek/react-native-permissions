#import "RNPermissions.h"
#import <React/RCTLog.h>

#if __has_include("RNPermissionHandlerBluetooth.h")
#import "RNPermissionHandlerBluetooth.h"
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
#if __has_include("RNPermissionHandlerCalendarsWriteOnly.h")
#import "RNPermissionHandlerCalendarsWriteOnly.h"
#endif

@interface RNPermissions()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<RNPermissionHandler>> *_Nonnull handlers;

@end

@implementation RNPermissions

RCT_EXPORT_MODULE();

+ (BOOL)requiresMainQueueSetup {
  return NO;
}

- (dispatch_queue_t)methodQueue {
  return dispatch_get_main_queue();
}

- (NSDictionary *)constantsToExport {
  NSMutableArray<NSString *> *available = [NSMutableArray new];

#if __has_include("RNPermissionHandlerBluetooth.h")
  [available addObject:[RNPermissionHandlerBluetooth handlerUniqueId]];
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
#if __has_include("RNPermissionHandlerCalendarsWriteOnly.h")
  [available addObject:[RNPermissionHandlerCalendarsWriteOnly handlerUniqueId]];
#endif

#if RCT_DEV
  if ([available count] == 0) {
    NSMutableString *message = [NSMutableString new];

    [message appendString:@"⚠  No permission handler detected.\n\n"];
    [message appendString:@"• Check that you are correctly calling setup_permissions in your Podfile.\n"];
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
      RCTLogWarn(@"Missing \"%@\" property in \"Info.plist\"", key);
      return;
    }
  }
#endif
}

- (id<RNPermissionHandler> _Nullable)handlerForPermission:(NSString *)permission {
  id<RNPermissionHandler> handler = nil;

  if (false) {}
#if __has_include("RNPermissionHandlerBluetooth.h")
  else if ([permission isEqualToString:[RNPermissionHandlerBluetooth handlerUniqueId]]) {
    handler = [RNPermissionHandlerBluetooth new];
  }
#endif
#if __has_include("RNPermissionHandlerCalendars.h")
  else if ([permission isEqualToString:[RNPermissionHandlerCalendars handlerUniqueId]]) {
    handler = [RNPermissionHandlerCalendars new];
  }
#endif
#if __has_include("RNPermissionHandlerCamera.h")
  else if ([permission isEqualToString:[RNPermissionHandlerCamera handlerUniqueId]]) {
    handler = [RNPermissionHandlerCamera new];
  }
#endif
#if __has_include("RNPermissionHandlerContacts.h")
  else if ([permission isEqualToString:[RNPermissionHandlerContacts handlerUniqueId]]) {
    handler = [RNPermissionHandlerContacts new];
  }
#endif
#if __has_include("RNPermissionHandlerFaceID.h")
  else if ([permission isEqualToString:[RNPermissionHandlerFaceID handlerUniqueId]]) {
    handler = [RNPermissionHandlerFaceID new];
  }
#endif
#if __has_include("RNPermissionHandlerLocationAlways.h")
  else if ([permission isEqualToString:[RNPermissionHandlerLocationAlways handlerUniqueId]]) {
    handler = [RNPermissionHandlerLocationAlways new];
  }
#endif
#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
  else if ([permission isEqualToString:[RNPermissionHandlerLocationWhenInUse handlerUniqueId]]) {
    handler = [RNPermissionHandlerLocationWhenInUse new];
  }
#endif
#if __has_include("RNPermissionHandlerMediaLibrary.h")
  else if ([permission isEqualToString:[RNPermissionHandlerMediaLibrary handlerUniqueId]]) {
    handler = [RNPermissionHandlerMediaLibrary new];
  }
#endif
#if __has_include("RNPermissionHandlerMicrophone.h")
  else if ([permission isEqualToString:[RNPermissionHandlerMicrophone handlerUniqueId]]) {
    handler = [RNPermissionHandlerMicrophone new];
  }
#endif
#if __has_include("RNPermissionHandlerMotion.h")
  else if ([permission isEqualToString:[RNPermissionHandlerMotion handlerUniqueId]]) {
    handler = [RNPermissionHandlerMotion new];
  }
#endif
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  else if ([permission isEqualToString:[RNPermissionHandlerPhotoLibrary handlerUniqueId]]) {
    handler = [RNPermissionHandlerPhotoLibrary new];
  }
#endif
#if __has_include("RNPermissionHandlerReminders.h")
  else if ([permission isEqualToString:[RNPermissionHandlerReminders handlerUniqueId]]) {
    handler = [RNPermissionHandlerReminders new];
  }
#endif
#if __has_include("RNPermissionHandlerSiri.h")
  else if ([permission isEqualToString:[RNPermissionHandlerSiri handlerUniqueId]]) {
    handler = [RNPermissionHandlerSiri new];
  }
#endif
#if __has_include("RNPermissionHandlerSpeechRecognition.h")
  else if ([permission isEqualToString:[RNPermissionHandlerSpeechRecognition handlerUniqueId]]) {
    handler = [RNPermissionHandlerSpeechRecognition new];
  }
#endif
#if __has_include("RNPermissionHandlerStoreKit.h")
  else if ([permission isEqualToString:[RNPermissionHandlerStoreKit handlerUniqueId]]) {
    handler = [RNPermissionHandlerStoreKit new];
  }
#endif
#if __has_include("RNPermissionHandlerAppTrackingTransparency.h")
  else if ([permission isEqualToString:[RNPermissionHandlerAppTrackingTransparency handlerUniqueId]]) {
    handler = [RNPermissionHandlerAppTrackingTransparency new];
  }
#endif
#if __has_include("RNPermissionHandlerPhotoLibraryAddOnly.h")
  else if ([permission isEqualToString:[RNPermissionHandlerPhotoLibraryAddOnly handlerUniqueId]]) {
    handler = [RNPermissionHandlerPhotoLibraryAddOnly new];
  }
#endif
#if __has_include("RNPermissionHandlerCalendarsWriteOnly.h")
  else if ([permission isEqualToString:[RNPermissionHandlerCalendarsWriteOnly handlerUniqueId]]) {
    handler = [RNPermissionHandlerCalendarsWriteOnly new];
  }
#endif
  else {
    RCTLogError(@"Unknown permission \"%@\"", permission);
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
    [_handlers removeObjectForKey:lockId];
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

RCT_EXPORT_METHOD(check:(NSString *)permission
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];
  NSString *lockId = [self lockHandler:handler];

  [handler checkWithResolver:^(RNPermissionStatus status) {
    resolve([self stringForStatus:status]);
    [self unlockHandler:lockId];
  } rejecter:^(NSError *error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  }];
}

RCT_EXPORT_METHOD(request:(NSString *)permission
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];
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

RCT_EXPORT_METHOD(openPhotoPicker:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  RNPermissionHandlerPhotoLibrary *handler = [RNPermissionHandlerPhotoLibrary new];
  [handler openPhotoPickerWithResolver:resolve rejecter:reject];
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

- (void)checkMultiple:(NSArray *)permissions
              resolve:(RCTPromiseResolveBlock)resolve
               reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:checkMultiple", @"checkMultiple is not supported on iOS", nil);
}

- (void)requestMultiple:(NSArray *)permissions
                resolve:(RCTPromiseResolveBlock)resolve
                 reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:requestMultiple", @"requestMultiple is not supported on iOS", nil);
}

- (void)shouldShowRequestRationale:(NSString *)permission
                           resolve:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:shouldShowRequestRationale", @"shouldShowRequestRationale is not supported on iOS", nil);
}

#if RCT_NEW_ARCH_ENABLED

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeRNPermissionsSpecJSI>(params);
}

- (facebook::react::ModuleConstants<JS::NativeRNPermissions::Constants::Builder>)getConstants {
  return [self constantsToExport];
}

#endif

@end
