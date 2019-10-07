import React from 'react';
import {Appbar, List, TouchableRipple} from 'react-native-paper';
import theme from './theme';

import {
  FlatList,
  Platform,
  StatusBar,
  Text,
  View,
  GestureResponderEvent,
} from 'react-native';

import RNPermissions, {
  PERMISSIONS,
  RESULTS,
  PermissionStatus,
  Permission,
  NotificationsResponse,
} from 'react-native-permissions';

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
  unavailable: 'lens',
  denied: 'error',
  granted: 'check-circle',
  blocked: 'cancel',
};

const PermissionRow = ({
  name,
  status,
  onPress,
}: {
  name: string;
  status: string;
  onPress: (event: GestureResponderEvent) => void;
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
  statuses: PermissionStatus[];
  notifications: NotificationsResponse;
}

function getSettingString(setting: boolean | undefined) {
  return setting
    ? RESULTS.GRANTED
    : setting === false
    ? RESULTS.DENIED
    : RESULTS.UNAVAILABLE;
}

export default class App extends React.Component<{}, State> {
  state: State = {
    statuses: [],
    notifications: {status: 'unavailable', settings: {}},
  };

  check = () =>
    Promise.all(PERMISSIONS_VALUES.map(_ => RNPermissions.check(_)))
      .then(statuses => this.setState({statuses}))
      .then(() => RNPermissions.checkNotifications())
      .then(notifications => this.setState({notifications}))
      .catch(error => console.warn(error));

  refresh = () => {
    this.setState({statuses: []}, this.check);
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
            onPress={RNPermissions.openSettings}
            icon="settings-applications"
          />
        </Appbar.Header>

        <FlatList
          keyExtractor={item => item}
          data={Object.keys(PLATFORM_PERMISSIONS)}
          renderItem={({item, index}) => {
            const value = PERMISSIONS_VALUES[index];
            const status = this.state.statuses[index];

            return (
              <PermissionRow
                status={status}
                name={item}
                onPress={() => {
                  RNPermissions.request(value)
                    .then(() => this.check())
                    .catch(console.error);
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
              .catch(err => console.error(err));
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
          {`alert: ${getSettingString(settings.alert)}\n`}
          {`badge: ${getSettingString(settings.badge)}\n`}
          {`sound: ${getSettingString(settings.sound)}\n`}
          {`lockScreen: ${getSettingString(settings.lockScreen)}\n`}
          {`notificationCenter: ${getSettingString(
            settings.notificationCenter,
          )}\n`}
          {`carPlay: ${getSettingString(settings.carPlay)}\n`}
          {`criticalAlert: ${getSettingString(settings.criticalAlert)}\n`}
        </Text>
      </View>
    );
  }
}
