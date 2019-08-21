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
  Permission,
  PermissionStatus,
  NotificationsResponse,
} from 'react-native-permissions';

const {PERMISSIONS} = RNPermissions;
// eslint-disable-next-line @typescript-eslint/no-unused-vars
const {SIRI, ...PERMISSIONS_IOS} = PERMISSIONS.IOS; // remove siri (certificate required)

const PLATFORM_PERMISSIONS = Platform.select({
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
                    .then(result => {
                      const statuses = [...this.state.statuses];
                      statuses[index] = result;
                      this.setState({statuses});
                    })
                    .then(() => this.check());
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
            RNPermissions.requestNotifications(['alert', 'badge', 'sound']);
          }}>
          <List.Item
            right={() => (
              <List.Icon
                color={colors[this.state.notifications.status]}
                icon={icons[this.state.notifications.status]}
              />
            )}
            title="NOTIFICATIONS"
            description={this.state.notifications.status}
          />
        </TouchableRipple>

        <Text style={{margin: 15, marginTop: 0, color: '#777'}}>
          {'settings = ' +
            JSON.stringify(this.state.notifications.settings, null, 2)}
        </Text>
      </View>
    );
  }
}
