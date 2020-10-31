import React from 'react';
import {AppState, Platform, ScrollView, StatusBar, Text, View} from 'react-native';
import {Appbar, List, TouchableRipple} from 'react-native-paper';
import RNPermissions, {
  NotificationsResponse,
  Permission,
  PERMISSIONS,
  PermissionStatus,
} from './src';
import theme from './theme';

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const {SIRI, ...PERMISSIONS_IOS} = PERMISSIONS.IOS; // remove siri (certificate required)

const PLATFORM_PERMISSIONS = Platform.select<
  typeof PERMISSIONS_IOS | typeof PERMISSIONS.ANDROID | typeof PERMISSIONS.WINDOWS | {}
>({
  ios: PERMISSIONS_IOS,
  android: PERMISSIONS.ANDROID,
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

const PermissionRow = ({
  name,
  status,
  onPress,
}: {
  name: string;
  status: string;
  onPress: () => void;
}) => (
  <TouchableRipple onPress={onPress} accessible={true} accessibilityLabel={`${name}:${status}`}>
    <List.Item
      right={() => <List.Icon color={colors[status]} icon={icons[status]} />}
      title={name}
      description={status}
    />
  </TouchableRipple>
);

type State = {
  statuses: Partial<Record<Permission, PermissionStatus>>;
  notifications: NotificationsResponse;
};

export default class App extends React.Component<{}, State> {
  state: State = {
    statuses: {},
    notifications: {status: 'unavailable', settings: {}},
  };

  check = () =>
    RNPermissions.checkMultiple(PERMISSIONS_VALUES)
      .then((statuses) => this.setState({statuses}))
      .then(() => RNPermissions.checkNotifications())
      .then((notifications) => this.setState({notifications}))
      .catch((error) => console.warn(error));

  refresh = () => {
    this.setState({statuses: {}}, this.check);
  };

  componentDidMount() {
    this.check();
    AppState.addEventListener('change', this.check);
  }

  componentWillUnmount() {
    AppState.removeEventListener('change', this.check);
  }

  render() {
    const {notifications} = this.state;
    const {settings} = notifications;

    return (
      <View style={{flex: 1, backgroundColor: theme.colors.background}}>
        <StatusBar backgroundColor={theme.colors.primary} barStyle="light-content" />

        <Appbar.Header>
          <Appbar.Content title="react-native-permissions" subtitle="Example application" />

          <Appbar.Action onPress={this.refresh} icon="refresh" />

          <Appbar.Action
            icon="image-multiple"
            onPress={() => {
              RNPermissions.openLimitedPhotoLibraryPicker();
            }}
          />

          <Appbar.Action
            icon="crosshairs-question"
            onPress={() => {
              RNPermissions.requestLocationAccuracy({
                purposeKey: 'full-accuracy',
              }).then((accuracy) => console.warn({accuracy}));
            }}
          />

          <Appbar.Action
            icon="cellphone-cog"
            onPress={() => {
              RNPermissions.openSettings();
            }}
          />
        </Appbar.Header>

        <ScrollView>
          {PERMISSIONS_VALUES.map(this.renderPermissionItem)}

          <View style={{backgroundColor: '#e0e0e0', height: 1}} accessibilityRole="none" />

          <TouchableRipple
            onPress={() => {
              RNPermissions.requestNotifications(['alert', 'badge', 'sound'])
                .then(() => this.check())
                .catch((error) => console.error(error));
            }}>
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
                  {`alert: ${settings.alert}\n`}
                  {`badge: ${settings.badge}\n`}
                  {`sound: ${settings.sound}\n`}
                  {`carPlay: ${settings.carPlay}\n`}
                  {`criticalAlert: ${settings.criticalAlert}\n`}
                  {`provisional: ${settings.provisional}\n`}
                  {`lockScreen: ${settings.lockScreen}\n`}
                  {`notificationCenter: ${settings.notificationCenter}\n`}
                </Text>
              )}
            </>
          </TouchableRipple>
        </ScrollView>
      </View>
    );
  }

  renderPermissionItem = (item: Permission, index: number) => {
    const value = PERMISSIONS_VALUES[index];
    const status = this.state.statuses[value];

    if (!status) {
      return null;
    }

    return (
      <PermissionRow
        status={status}
        key={item}
        name={item}
        onPress={() => {
          RNPermissions.request(value)
            .then(() => this.check())
            .catch((error) => console.error(error));
        }}
      />
    );
  };
}
