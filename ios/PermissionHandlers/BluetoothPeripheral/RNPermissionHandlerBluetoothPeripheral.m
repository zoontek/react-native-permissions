#import "RNPermissionHandlerBluetoothPeripheral.h"

@import CoreBluetooth;

@interface RNPermissionHandlerBluetoothPeripheral() <CBPeripheralManagerDelegate>

@property (nonatomic) CBPeripheralManager* peripheralManager;
@property (nonatomic, copy) void (^resolve)(RNPermissionStatus status);
@property (nonatomic, copy) void (^reject)(NSError *error);

@end

@implementation RNPermissionHandlerBluetoothPeripheral

+ (NSArray<NSString *> *)usageDescriptionKeys {
  return @[@"NSBluetoothPeripheralUsageDescription"];
}

- (void)checkWithResolver:(void (^)(RNPermissionStatus status))resolve
             withRejecter:(void (__unused ^)(NSError *error))reject {
#if TARGET_OS_SIMULATOR
  return resolve(RNPermissionStatusNotAvailable);
#else
  if (![RNPermissionsManager hasBackgroundModeEnabled:@"bluetooth-peripheral"]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

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
#endif
}

- (void)requestWithOptions:(__unused NSDictionary * _Nullable)options
              withResolver:(void (^)(RNPermissionStatus status))resolve
              withRejecter:(void (^)(NSError *error))reject {
  if (![RNPermissionsManager hasBackgroundModeEnabled:@"bluetooth-peripheral"]) {
    return resolve(RNPermissionStatusNotAvailable);
  }

  _resolve = resolve;
  _reject = reject;

  _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{
    CBPeripheralManagerOptionShowPowerAlertKey: @false,
  }];

  [_peripheralManager startAdvertising:@{}];
}

- (void)peripheralManagerDidUpdateState:(nonnull CBPeripheralManager *)peripheral {
  int state = peripheral.state;

  [_peripheralManager stopAdvertising];
  _peripheralManager = nil;

  switch (state) {
    case CBManagerStatePoweredOff:
    case CBManagerStateResetting:
    case CBManagerStateUnsupported:
      return _resolve(RNPermissionStatusNotAvailable);
    case CBManagerStateUnknown:
      return _resolve(RNPermissionStatusNotDetermined);
    case CBManagerStateUnauthorized:
      return _resolve(RNPermissionStatusDenied);
    case CBManagerStatePoweredOn:
      return [self checkWithResolver:_resolve withRejecter:_reject];
  }
}

@end
