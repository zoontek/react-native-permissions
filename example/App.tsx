import React from 'react';
import {FlatList, Platform, StatusBar, Text, View} from 'react-native';
import {Appbar, List, TouchableRipple} from 'react-native-paper';
import RNPermissions, {
  NotificationsResponse,
  Permission,
  PERMISSIONS,
  PermissionStatus,
  RESULTS,
} from 'react-native-permissions';
import theme from './theme';

// eslint-disable-next-line @typescript-eslint/no-unused-vars
const {SIRI, ...PERMISSIONS_IOS} = PERMISSIONS.IOS; // remove siri (certificate required)

const PLATFORM_PERMISSIONS = Platform.select<
  typeof PERMISSIONS_IOS | typeof PERMISSIONS.ANDROID | {}
>({
  ios: PERMISSIONS_IOS,
  android: PERMISSIONS.ANDROID,
  default: {},
});

const PERMISSIONS_VALUES: Permission[] = Object.values(PLATFORM_PERMISSIONS);

const colors: {[key: string]: string} = {
  unavailable: '#cfd8dc',
  denied: '#ff9800',
  granted: '#43a047',
  blocked: '#e53935',
};

const icons: {[key: string]: string} = {
  unavailable: 'circle',
  denied: 'alert-circle',
  granted: 'check-circle',
  blocked: 'close-circle',
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
  <TouchableRipple onPress={onPress}>
    <List.Item
      right={() => <List.Icon color={colors[status]} icon={icons[status]} />}
      title={name}
      description={status}
    />
  </TouchableRipple>
);

interface State {
  statuses: Partial<Record<Permission, PermissionStatus>>;
  notifications: NotificationsResponse;
}

function toSettingString(setting: boolean | undefined) {
  switch (setting) {
    case true:
      return RESULTS.GRANTED;
    case false:
      return RESULTS.DENIED;
    default:
      return RESULTS.UNAVAILABLE;
  }
}

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
  }

  render() {
    const {notifications} = this.state;
    const {settings} = notifications;

    return (
      <View style={{flex: 1, backgroundColor: theme.colors.background}}>
        <StatusBar
          backgroundColor={theme.colors.primary}
          barStyle="light-content"
        />

        <Appbar.Header>
          <Appbar.Content
            title="react-native-permissions"
            subtitle="Example application"
          />

          <Appbar.Action onPress={this.refresh} icon="refresh" />

          <Appbar.Action
            icon="settings"
            onPress={() => {
              RNPermissions.openSettings();
            }}
          />
        </Appbar.Header>

        <FlatList
          keyExtractor={(item) => item}
          data={Object.keys(PLATFORM_PERMISSIONS)}
          renderItem={({item, index}) => {
            const value = PERMISSIONS_VALUES[index];
            const status = this.state.statuses[value];

            if (!status) {
              return null;
            }

            return (
              <PermissionRow
                status={status}
                name={item}
                onPress={() => {
                  RNPermissions.request(value)
                    .then(() => this.check())
                    .catch((error) => console.error(error));
                }}
              />
            );
          }}
        />

        <View
          style={{backgroundColor: '#e0e0e0', height: 1}}
          accessibilityRole="none"
        />

        <TouchableRipple
          onPress={() => {
            RNPermissions.requestNotifications(['alert', 'badge', 'sound'])
              .then(() => this.check())
              .catch((error) => console.error(error));
          }}>
          <List.Item
            right={() => (
              <List.Icon
                color={colors[notifications.status]}
                icon={icons[notifications.status]}
              />
            )}
            title="NOTIFICATIONS"
            description={notifications.status}
          />
        </TouchableRipple>

        <Text style={{margin: 15, marginTop: 0, color: '#777'}}>
          {`alert: ${toSettingString(settings.alert)}\n`}
          {`badge: ${toSettingString(settings.badge)}\n`}
          {`sound: ${toSettingString(settings.sound)}\n`}
          {`lockScreen: ${toSettingString(settings.lockScreen)}\n`}
          {`notificationCenter: ${toSettingString(
            settings.notificationCenter,
          )}\n`}
          {`carPlay: ${toSettingString(settings.carPlay)}\n`}
          {`criticalAlert: ${toSettingString(settings.criticalAlert)}\n`}
        </Text>
      </View>
    );
  }
}
