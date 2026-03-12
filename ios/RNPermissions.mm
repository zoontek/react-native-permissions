#import "RNPermissions.h"
#import <React/RCTLog.h>

static NSString* SETTING_KEY = @"@RNPermissions:Requested";

@protocol RNPermissionHandlerClass <NSObject>
+ (NSString * _Nonnull)handlerUniqueId;
+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys;
@end

@protocol RNPermissionHandlerNotificationsClass <RNPermissionHandlerClass>
- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve;
- (void)requestWithOptions:(NSArray<NSString *> * _Nonnull)options
                  resolver:(void (^ _Nonnull)(RNPermissionStatus status, NSDictionary * _Nonnull settings))resolve
                  rejecter:(void (^ _Nonnull)(NSError * _Nonnull error))reject;
@end

@protocol RNPermissionHandlerPhotoLibraryClass <RNPermissionHandlerClass>
- (void)openPhotoPickerWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                           rejecter:(RCTPromiseRejectBlock _Nonnull)reject;
@end

@protocol RNPermissionHandlerLocationAccuracyClass <RNPermissionHandlerClass>
- (void)checkWithResolver:(RCTPromiseResolveBlock _Nonnull)resolve
                 rejecter:(RCTPromiseRejectBlock _Nonnull)reject;
- (void)requestWithPurposeKey:(NSString * _Nonnull)purposeKey
                     resolver:(RCTPromiseResolveBlock _Nonnull)resolve
                     rejecter:(RCTPromiseRejectBlock _Nonnull)reject;
@end

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

- (NSArray<NSString *> *)handlerClassNames {
  return @[
    @"RNPermissionHandlerBluetooth",
    @"RNPermissionHandlerCalendars",
    @"RNPermissionHandlerCamera",
    @"RNPermissionHandlerContacts",
    @"RNPermissionHandlerFaceID",
    @"RNPermissionHandlerLocationAlways",
    @"RNPermissionHandlerLocationWhenInUse",
    @"RNPermissionHandlerMediaLibrary",
    @"RNPermissionHandlerMicrophone",
    @"RNPermissionHandlerMotion",
    @"RNPermissionHandlerPhotoLibrary",
    @"RNPermissionHandlerReminders",
    @"RNPermissionHandlerSiri",
    @"RNPermissionHandlerSpeechRecognition",
    @"RNPermissionHandlerStoreKit",
    @"RNPermissionHandlerAppTrackingTransparency",
    @"RNPermissionHandlerPhotoLibraryAddOnly",
    @"RNPermissionHandlerCalendarsWriteOnly",
  ];
}

- (id<RNPermissionHandler> _Nullable)runtimeHandlerForClassName:(NSString *)className
                                                     permission:(NSString *)permission {
  Class handlerClass = NSClassFromString(className);

  if (handlerClass == nil) {
    return nil;
  }

  id<RNPermissionHandlerClass> typedHandlerClass = (id<RNPermissionHandlerClass>)handlerClass;

  if ([permission isEqualToString:[typedHandlerClass handlerUniqueId]]) {
    return [self checkPermissionHandler:(id<RNPermissionHandler>)[handlerClass new]];
  }

  return nil;
}

- (id<RNPermissionHandler> _Nullable)handlerForPermission:(NSString *)permission {
  bool hasPermissionHandlers = false;

  for (NSString *className in [self handlerClassNames]) {
    hasPermissionHandlers = hasPermissionHandlers || (NSClassFromString(className) != nil);
    id<RNPermissionHandler> handler = [self runtimeHandlerForClassName:className permission:permission];

    if (handler != nil) {
      return handler;
    }
  }

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
  Class handlerClass = NSClassFromString(@"RNPermissionHandlerNotifications");
  if (handlerClass == nil) {
    reject(@"notifications_pod_missing", @"Notifications permission pod is missing", nil);
    return;
  }

  id<RNPermissionHandlerNotificationsClass> handler = (id<RNPermissionHandlerNotificationsClass>)[handlerClass new];
  NSString *lockId = [self lockHandler:(id<RNPermissionHandler>)handler];

  [handler checkWithResolver:^(RNPermissionStatus status, NSDictionary * _Nonnull settings) {
    resolve(@{ @"status": [self stringForStatus:status], @"settings": settings });
    [self unlockHandler:lockId];
  }];
}

RCT_EXPORT_METHOD(requestNotifications:(NSArray<NSString *> * _Nonnull)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  Class handlerClass = NSClassFromString(@"RNPermissionHandlerNotifications");
  if (handlerClass == nil) {
    reject(@"notifications_pod_missing", @"Notifications permission pod is missing", nil);
    return;
  }

  id<RNPermissionHandlerNotificationsClass> handler = (id<RNPermissionHandlerNotificationsClass>)[handlerClass new];
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
}

RCT_EXPORT_METHOD(openPhotoPicker:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  Class handlerClass = NSClassFromString(@"RNPermissionHandlerPhotoLibrary");
  if (handlerClass == nil) {
    reject(@"photo_library_pod_missing", @"PhotoLibrary permission pod is missing", nil);
    return;
  }

  id<RNPermissionHandlerPhotoLibraryClass> handler = (id<RNPermissionHandlerPhotoLibraryClass>)[handlerClass new];
  [handler openPhotoPickerWithResolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(checkLocationAccuracy:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  Class handlerClass = NSClassFromString(@"RNPermissionHandlerLocationAccuracy");
  if (handlerClass == nil) {
    reject(@"location_accuracy_pod_missing", @"LocationAccuracy permission pod is missing", nil);
    return;
  }

  id<RNPermissionHandlerLocationAccuracyClass> handler = (id<RNPermissionHandlerLocationAccuracyClass>)[handlerClass new];
  [self checkUsageDescriptionKeys:[[handler class] usageDescriptionKeys]];
  [handler checkWithResolver:resolve rejecter:reject];
}

RCT_EXPORT_METHOD(requestLocationAccuracy:(NSString * _Nonnull)purposeKey
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {
  Class handlerClass = NSClassFromString(@"RNPermissionHandlerLocationAccuracy");
  if (handlerClass == nil) {
    reject(@"location_accuracy_pod_missing", @"LocationAccuracy permission pod is missing", nil);
    return;
  }

  id<RNPermissionHandlerLocationAccuracyClass> handler = (id<RNPermissionHandlerLocationAccuracyClass>)[handlerClass new];
  [self checkUsageDescriptionKeys:[[handler class] usageDescriptionKeys]];
  [handler requestWithPurposeKey:purposeKey resolver:resolve rejecter:reject];
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

- (void)canUseFullScreenIntent:(RCTPromiseResolveBlock)resolve
                        reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:canUseFullScreenIntent", @"canUseFullScreenIntent is not supported on iOS", nil);
}

- (void)shouldShowRequestRationale:(NSString *)permission
                           resolve:(RCTPromiseResolveBlock)resolve
                            reject:(RCTPromiseRejectBlock)reject {
  reject(@"RNPermissions:shouldShowRequestRationale", @"shouldShowRequestRationale is not supported on iOS", nil);
}

#endif

@end
