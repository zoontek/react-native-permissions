#import "RNPermissionHandlerPhotoLibrary.h"

@import Photos;

@implementation RNPermissionHandlerPhotoLibrary

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSPhotoLibraryUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
  switch ([PHPhotoLibrary authorizationStatus]) {
    case PHAuthorizationStatusNotDetermined:
      return resolve(RNPermissionStatusNotDetermined);
    case PHAuthorizationStatusRestricted:
      return resolve(RNPermissionStatusRestricted);
    case PHAuthorizationStatusDenied:
      return resolve(RNPermissionStatusDenied);
    case PHAuthorizationStatusAuthorized:
      return resolve(RNPermissionStatusAuthorized);
  }
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  [PHPhotoLibrary requestAuthorization:^(__unused PHAuthorizationStatus status) {
    [self checkWithResolver:resolve withRejecter:reject];
  }];
}

@end
