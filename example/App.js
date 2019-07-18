// @flow

import React from 'react';
import Permissions, {type PermissionStatus} from 'react-native-permissions';

import {
  StyleSheet,
  TouchableHighlight,
  Text,
  View,
  Alert,
  AppState,
  Platform,
} from 'react-native';

type State = {
  types: string[],
  status: {[permission: string]: PermissionStatus},
  isAlways: boolean,
};

export default class App extends React.Component<{}, State> {
  state: State = {
    types: [],
    status: {},
    isAlways: false,
    statuses: {},
  };

  componentDidMount() {
    const types = Permissions.getTypes();

    this.setState({types});
    this.updatePermissions(types);

    AppState.addEventListener('change', this.onAppStateChange);
  }

  componentWillUnmount() {
    AppState.removeEventListener('change', this.onAppStateChange);
  }

  onAppStateChange = (appState: 'active' | 'inactive' | 'background') => {
    if (appState === 'active') {
      this.updatePermissions(this.state.types);
    }
  };

  openSettings = () =>
    Permissions.canOpenSettings().then(canIt => {
      if (canIt) {
        return Permissions.openSettings();
      }

      Alert.alert(
        'Not supported',
        'openSettings is currently not supported on this platform',
      );
    });

  updatePermissions = (types: string[]) => {
    Permissions.checkMultiple(types)
      .then(status => {
        if (this.state.isAlways) {
          return Permissions.check('location', 'always').then(location => ({
            ...status,
            location,
          }));
        }
        return status;
      })
      .then(status => this.setState({status}));
  };

  requestPermission = (permission: string) => {
    var options;

    if (permission == 'location') {
      options = this.state.isAlways ? 'always' : 'whenInUse';
    }

    Permissions.request(permission, options)
      .then(result => {
        this.setState({
          status: {...this.state.status, [permission]: result},
        });

        if (result != 'authorized') {
          Alert.alert(
            'Whoops!',
            'There was a problem getting your permission. Please enable it from settings.',
            [{text: 'Cancel', style: 'cancel'}],
          );
        }
      })
      .catch(error => console.warn(error));
  };

  onLocationSwitchChange = () => {
    this.setState({isAlways: !this.state.isAlways});
    this.updatePermissions(this.state.types);
  };

  render() {
    return (
      <View style={styles.container}>
        {this.state.types.map(permission => (
          <TouchableHighlight
            style={[styles.button, styles[this.state.status[permission]]]}
            key={permission}
            onPress={() => this.requestPermission(permission)}>
            <View>
              <Text style={styles.text}>
                {Platform.OS == 'ios' && permission == 'location'
                  ? `location ${this.state.isAlways ? 'always' : 'whenInUse'}`
                  : permission}
              </Text>

              <Text style={styles.subtext}>
                {this.state.status[permission]}
              </Text>
            </View>
          </TouchableHighlight>
        ))}

        <View style={styles.footer}>
          <TouchableHighlight
            style={styles['footer_' + Platform.OS]}
            onPress={this.onLocationSwitchChange}>
            <Text style={styles.text}>Toggle location type</Text>
          </TouchableHighlight>

          <TouchableHighlight onPress={this.openSettings}>
            <Text style={styles.text}>Open settings</Text>
          </TouchableHighlight>
        </View>

        <Text style={styles['footer_' + Platform.OS]}>
          Note: microphone permissions may not work on iOS simulator. Also,
          toggling permissions from the settings menu may cause the app to
          crash. This is normal on iOS. Google "ios crash permission change"
        </Text>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    backgroundColor: '#F5FCFF',
    padding: 10,
  },
  text: {
    textAlign: 'center',
    fontWeight: 'bold',
  },
  subtext: {
    textAlign: 'center',
  },
  button: {
    margin: 5,
    borderColor: 'black',
    borderWidth: 3,
    overflow: 'hidden',
  },
  buttonInner: {
    flexDirection: 'column',
  },
  undetermined: {
    backgroundColor: '#E0E0E0',
  },
  authorized: {
    backgroundColor: '#C5E1A5',
  },
  denied: {
    backgroundColor: '#ef9a9a',
  },
  restricted: {
    backgroundColor: '#ef9a9a',
  },
  footer: {
    padding: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  footer_android: {
    height: 0,
    width: 0,
  },
});
