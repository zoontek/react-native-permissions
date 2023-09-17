#import "RNPermissionHandlerBluetoothPeripheral.h"

@import CoreBluetooth;

@interface RNPermissionHandlerBluetoothPeripheral() <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager* manager;
@property (nonatomic, strong) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, strong) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerBluetoothPeripheral

+ (NSArray<NSString *> * _Nonnull)usageDescriptionKeys {
  return @[
    @"NSBluetoothAlwaysUsageDescription",
    @"NSBluetoothPeripheralUsageDescription",
  ];
}

+ (NSString * _Nonnull)handlerUniqueId {
  return @"ios.permission.BLUETOOTH_PERIPHERAL";
}

- (void)checkWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                 rejecter:(void (__unused ^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_SIMULATOR
  return resolve(RNPermissionStatusNotAvailable);
#else

  if (@available(iOS 13.1, *)) {
    switch ([CBManager authorization]) {
      case CBManagerAuthorizationNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case CBManagerAuthorizationRestricted:
        return resolve(RNPermissionStatusRestricted);
      case CBManagerAuthorizationDenied:
        return resolve(RNPermissionStatusDenied);
      case CBManagerAuthorizationAllowedAlways:
        return resolve(RNPermissionStatusAuthorized);
    }
  } else {
    switch ([CBPeripheralManager authorizationStatus]) {
      case CBPeripheralManagerAuthorizationStatusNotDetermined:
        return resolve(RNPermissionStatusNotDetermined);
      case CBPeripheralManagerAuthorizationStatusRestricted:
        return resolve(RNPermissionStatusRestricted);
      case CBPeripheralManagerAuthorizationStatusDenied:
        return resolve(RNPermissionStatusDenied);
      case CBPeripheralManagerAuthorizationStatusAuthorized:
        return resolve(RNPermissionStatusAuthorized);
    }
  }
#endif
}

- (void)requestWithResolver:(void (^ _Nonnull)(RNPermissionStatus))resolve
                   rejecter:(void (^ _Nonnull)(NSError * _Nonnull))reject {
#if TARGET_OS_SIMULATOR
  return resolve(RNPermissionStatusNotAvailable);
#else
  _resolve = resolve;
  _reject = reject;

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
      return [self checkWithResolver:_resolve rejecter:_reject];
  }
}

@end
