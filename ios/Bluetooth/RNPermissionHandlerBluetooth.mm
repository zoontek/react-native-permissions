#import "RNPermissionHandlerBluetooth.h"

#import <CoreBluetooth/CoreBluetooth.h>

@interface RNPermissionHandlerBluetooth() <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager* manager;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);

@end

@implementation RNPermissionHandlerBluetooth

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[
    @"NSBluetoothAlwaysUsageDescription",
    @"NSBluetoothPeripheralUsageDescription",
  ];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.BLUETOOTH";
}

- (RNPermissionStatus)currentStatus {
#if TARGET_OS_TV || TARGET_OS_SIMULATOR
  return RNPermissionStatusNotAvailable;
#else
  switch ([CBManager authorization]) {
    case CBManagerAuthorizationNotDetermined:
      return RNPermissionStatusNotDetermined;
    case CBManagerAuthorizationRestricted:
      return RNPermissionStatusRestricted;
    case CBManagerAuthorizationDenied:
      return RNPermissionStatusDenied;
    case CBManagerAuthorizationAllowedAlways:
      return RNPermissionStatusAuthorized;
  }
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_TV || TARGET_OS_SIMULATOR
  return resolve(RNPermissionStatusNotAvailable);
#else
  _resolve = resolve;

  _manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{
    CBPeripheralManagerOptionShowPowerAlertKey: @false,
  }];
#endif
}

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
  switch (peripheral.state) {
    case CBManagerStatePoweredOff:
    case CBManagerStateResetting:
    case CBManagerStateUnsupported:
      return _resolve(RNPermissionStatusNotAvailable);
    case CBManagerStateUnknown:
      return _resolve(RNPermissionStatusNotDetermined);
    case CBManagerStateUnauthorized:
      return _resolve(RNPermissionStatusDenied);
    case CBManagerStatePoweredOn:
      return _resolve([self currentStatus]);
  }
}

@end
