import * as React from 'react';
import {AppState, Platform, ScrollView, StatusBar, Text, View} from 'react-native';
import {Appbar, List, TouchableRipple} from 'react-native-paper';
import RNPermissions, {
  NotificationsResponse,
  Permission,
  PERMISSIONS,
  PermissionStatus,
} from 'react-native-permissions';
import theme from './theme';

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const {SIRI, ...PERMISSIONS_IOS} = PERMISSIONS.IOS; // remove siri (certificate required)

const PLATFORM_PERMISSIONS = Platform.select<
  typeof PERMISSIONS.ANDROID | typeof PERMISSIONS_IOS | typeof PERMISSIONS.WINDOWS | {}
>({
  android: PERMISSIONS.ANDROID,
  ios: PERMISSIONS_IOS,
  windows: PERMISSIONS.WINDOWS,
  default: {},
});

const PERMISSIONS_VALUES: Permission[] = Object.values(PLATFORM_PERMISSIONS);

const colors: {[key: string]: string} = {
  unavailable: '#cfd8dc',
  denied: '#ff9800',
  granted: '#43a047',
  blocked: '#e53935',
  limited: '#a1887f',
};

const icons: {[key: string]: string} = {
  unavailable: 'circle',
  denied: 'alert-circle',
  granted: 'check-circle',
  blocked: 'close-circle',
  limited: 'alpha-l-circle',
};

export const App = () => {
  const [statuses, setStatuses] = React.useState<Partial<Record<Permission, PermissionStatus>>>({});
  const [notifications, setNotifications] = React.useState<NotificationsResponse>({
    settings: {},
    status: 'unavailable',
  });

  const check = React.useCallback(() => {
    RNPermissions.checkMultiple(PERMISSIONS_VALUES)
      .then(setStatuses)
      .then(() => RNPermissions.checkNotifications())
      .then(setNotifications)
      .catch((error) => console.warn(error));
  }, []);

  React.useEffect(() => {
    const {remove} = AppState.addEventListener(
      'change',
      (status) => status === 'active' && check(),
    );

    return remove;
  }, [check]);

  return (
    <View style={{flex: 1, backgroundColor: theme.colors.background}}>
      <StatusBar backgroundColor={theme.colors.primary} barStyle="light-content" />

      <Appbar.Header>
        <Appbar.Content title="react-native-permissions" subtitle="Example application" />
        <Appbar.Action onPress={check} icon="refresh" />

        {Platform.OS === 'ios' && (
          <Appbar.Action
            icon="image-multiple"
            onPress={() => {
              RNPermissions.openLimitedPhotoLibraryPicker();
            }}
          />
        )}

        {Platform.OS === 'ios' && (
          <Appbar.Action
            icon="crosshairs-question"
            onPress={() => {
              RNPermissions.requestLocationAccuracy({
                purposeKey: 'full-accuracy',
              }).then((accuracy) => console.warn({accuracy}));
            }}
          />
        )}

        <Appbar.Action
          icon="cellphone-cog"
          onPress={() => {
            RNPermissions.openSettings();
          }}
        />
      </Appbar.Header>

      <ScrollView>
        {PERMISSIONS_VALUES.map((item, index) => {
          const value = PERMISSIONS_VALUES[index];
          const status = statuses[value];

          if (!status) {
            return null;
          }

          return (
            <TouchableRipple
              key={item}
              onPress={() => {
                RNPermissions.request(value)
                  .then(check)
                  .catch((error) => console.error(error));
              }}
            >
              <List.Item
                right={() => <List.Icon color={colors[status]} icon={icons[status]} />}
                title={item}
                description={status}
              />
            </TouchableRipple>
          );
        })}

        <View style={{backgroundColor: '#e0e0e0', height: 1}} />

        <TouchableRipple
          onPress={() => {
            RNPermissions.requestNotifications(['alert', 'badge', 'sound', 'providesAppSettings'])
              .then(check)
              .catch((error) => console.error(error));
          }}
        >
          <>
            <List.Item
              title="NOTIFICATIONS"
              right={() => (
                <List.Icon
                  color={colors[notifications.status]}
                  icon={icons[notifications.status]}
                />
              )}
            />

            {Platform.OS === 'ios' && (
              <Text style={{margin: 15, marginTop: -24, color: '#777'}}>
                {`alert: ${notifications.settings.alert}\n`}
                {`badge: ${notifications.settings.badge}\n`}
                {`sound: ${notifications.settings.sound}\n`}
                {`carPlay: ${notifications.settings.carPlay}\n`}
                {`criticalAlert: ${notifications.settings.criticalAlert}\n`}
                {`provisional: ${notifications.settings.provisional}\n`}
                {`providesAppSettings: ${notifications.settings.providesAppSettings}\n`}
                {`lockScreen: ${notifications.settings.lockScreen}\n`}
                {`notificationCenter: ${notifications.settings.notificationCenter}\n`}
              </Text>
            )}
          </>
        </TouchableRipple>
      </ScrollView>
    </View>
  );
};
