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

static NSString* SETTING_KEY = @"@RNPermissions:Requested";

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

- (id<RNPermissionHandler>)checkPermissionHandler:(id<RNPermissionHandler>)handler {
  [self checkUsageDescriptionKeys:[[handler class] usageDescriptionKeys]];
  return handler;
}

- (id<RNPermissionHandler> _Nullable)handlerForPermission:(NSString *)permission {
  bool hasPermissionHandlers = false;

#if __has_include("RNPermissionHandlerBluetooth.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerBluetooth handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerBluetooth new]];
  }
#endif

#if __has_include("RNPermissionHandlerCalendars.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerCalendars handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerCalendars new]];
  }
#endif

#if __has_include("RNPermissionHandlerCamera.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerCamera handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerCamera new]];
  }
#endif

#if __has_include("RNPermissionHandlerContacts.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerContacts handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerContacts new]];
  }
#endif

#if __has_include("RNPermissionHandlerFaceID.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerFaceID handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerFaceID new]];
  }
#endif

#if __has_include("RNPermissionHandlerLocationAlways.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerLocationAlways handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerLocationAlways new]];
  }
#endif

#if __has_include("RNPermissionHandlerLocationWhenInUse.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerLocationWhenInUse handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerLocationWhenInUse new]];
  }
#endif

#if __has_include("RNPermissionHandlerMediaLibrary.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerMediaLibrary handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerMediaLibrary new]];
  }
#endif

#if __has_include("RNPermissionHandlerMicrophone.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerMicrophone handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerMicrophone new]];
  }
#endif

#if __has_include("RNPermissionHandlerMotion.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerMotion handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerMotion new]];
  }
#endif

#if __has_include("RNPermissionHandlerPhotoLibrary.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerPhotoLibrary handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerPhotoLibrary new]];
  }
#endif

#if __has_include("RNPermissionHandlerReminders.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerReminders handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerReminders new]];
  }
#endif

#if __has_include("RNPermissionHandlerSiri.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerSiri handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerSiri new]];
  }
#endif

#if __has_include("RNPermissionHandlerSpeechRecognition.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerSpeechRecognition handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerSpeechRecognition new]];
  }
#endif

#if __has_include("RNPermissionHandlerStoreKit.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerStoreKit handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerStoreKit new]];
  }
#endif

#if __has_include("RNPermissionHandlerAppTrackingTransparency.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerAppTrackingTransparency handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerAppTrackingTransparency new]];
  }
#endif

#if __has_include("RNPermissionHandlerPhotoLibraryAddOnly.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerPhotoLibraryAddOnly handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerPhotoLibraryAddOnly new]];
  }
#endif

#if __has_include("RNPermissionHandlerCalendarsWriteOnly.h")
  hasPermissionHandlers = true;

  if ([permission isEqualToString:[RNPermissionHandlerCalendarsWriteOnly handlerUniqueId]]) {
    return [self checkPermissionHandler:[RNPermissionHandlerCalendarsWriteOnly new]];
  }
#endif

#if RCT_DEV
  NSMutableString *message = [NSMutableString new];

  NSString *title = hasPermissionHandlers
    ? [NSString stringWithFormat:@"No \"%@\" permission handler detected", permission]
    : @"No permission handler detected";

  [message appendString:[NSString stringWithFormat:@"⚠  %@.\n\n", title]];
  [message appendString:@"• Check that you have correctly set up setup_permissions in your Podfile.\n"];
  [message appendString:@"• Uninstall this app, reinstall your Pods, delete your Xcode DerivedData folder and rebuild it.\n"];

  RCTLogError(@"%@", message);
#endif

  return nil;
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

+ (void)flagAsRequested:(NSString * _Nonnull)handlerId {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSMutableArray<NSString *> *requested = [[userDefaults arrayForKey:SETTING_KEY] mutableCopy];

  if (requested == nil) {
    requested = [NSMutableArray new];
  }

  if (![requested containsObject:handlerId]) {
    [requested addObject:handlerId];
    [userDefaults setObject:requested forKey:SETTING_KEY];
    [userDefaults synchronize];
  }
}

+ (bool)isFlaggedAsRequested:(NSString * _Nonnull)handlerId {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSArray<NSString *> *requested = [userDefaults arrayForKey:SETTING_KEY];

  return requested != nil && [requested containsObject:handlerId];
}

RCT_EXPORT_METHOD(openSettings:(NSString *)type
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  UIApplication *sharedApplication = [UIApplication sharedApplication];
  NSString *urlString = UIApplicationOpenSettingsURLString;

  if (@available(iOS 15.4, tvOS 15.4, *)) {
    if ([type isEqualToString:@"notifications"]) {
      urlString = UIApplicationOpenNotificationSettingsURLString;
    }
  }

  [sharedApplication openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success) {
    if (success) {
      resolve(@(true));
    } else {
      reject(@"cannot_open_settings", [NSString stringWithFormat:@"Cannot open %@ settings", type], nil);
    }
  }];
}

RCT_EXPORT_METHOD(check:(NSString *)permission
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> handler = [self handlerForPermission:permission];
  resolve([self stringForStatus:(handler != nil ? [handler currentStatus] : RNPermissionStatusNotAvailable)]);
}

RCT_EXPORT_METHOD(request:(NSString *)permission
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  id<RNPermissionHandler> _Nullable handler = [self handlerForPermission:permission];

  if (handler == nil) {
    resolve([self stringForStatus:RNPermissionStatusNotAvailable]);
  } else {
    NSString *lockId = [self lockHandler:handler];

    [handler requestWithResolver:^(RNPermissionStatus status) {
      resolve([self stringForStatus:status]);
      [self unlockHandler:lockId];
    }
                        rejecter:^(NSError *error) {
      reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
      [self unlockHandler:lockId];
    }];
  }
}

RCT_EXPORT_METHOD(checkNotifications:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
#if __has_include("RNPermissionHandlerNotifications.h")
  RNPermissionHandlerNotifications *handler = [RNPermissionHandlerNotifications new];
  NSString *lockId = [self lockHandler:(id<RNPermissionHandler>)handler];

  [handler checkWithResolver:^(RNPermissionStatus status, NSDictionary * _Nonnull settings) {
    resolve(@{ @"status": [self stringForStatus:status], @"settings": settings });
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

  [handler requestWithOptions:options
                     resolver:^(RNPermissionStatus status, NSDictionary * _Nonnull settings) {
    resolve(@{ @"status": [self stringForStatus:status], @"settings": settings });
    [self unlockHandler:lockId];
  }
                     rejecter:^(NSError * _Nonnull error) {
    reject([NSString stringWithFormat:@"%ld", (long)error.code], error.localizedDescription, error);
    [self unlockHandler:lockId];
  }];
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

#if RCT_NEW_ARCH_ENABLED

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return std::make_shared<facebook::react::NativeRNPermissionsSpecJSI>(params);
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

- (void)canScheduleExactAlarms:(RCTPromiseResolveBlock)resolve
                        reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:canScheduleExactAlarms", @"canScheduleExactAlarms is not supported on iOS", nil);
}

- (void)shouldShowRequestRationale:(NSString *)permission
                           resolve:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:shouldShowRequestRationale", @"shouldShowRequestRationale is not supported on iOS", nil);
}

#endif

@end
