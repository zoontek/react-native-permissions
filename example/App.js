// @flow

import * as React from "react";
import { Appbar, List, TouchableRipple, Snackbar } from "react-native-paper";
import * as RNPermissions from "react-native-permissions";
import type { PermissionStatus } from "react-native-permissions";
import theme from "./theme";

import {
  AppState,
  Platform,
  StatusBar,
  ScrollView,
  StyleSheet,
  Text,
  View,
} from "react-native";

// $FlowFixMe
let platformPermissions: string[] = Object.values(
  Platform.OS === "ios"
    ? RNPermissions.IOS_PERMISSIONS
    : RNPermissions.ANDROID_PERMISSIONS,
).filter(permission => permission !== "SIRI");

const statusColors: { [PermissionStatus]: string } = {
  granted: "#43a047",
  denied: "#ff9800",
  never_ask_again: "#e53935",
  unavailable: "#cfd8dc",
};

const statusIcons: { [PermissionStatus]: string } = {
  granted: "check-circle",
  denied: "error",
  never_ask_again: "cancel",
  unavailable: "lens",
};

type AppStateType = "active" | "background" | "inactive";

type Props = {};

// RNPermissions.checkMultiple([
//   RNPermissions.ANDROID_PERMISSIONS.ACCESS_FINE_LOCATION,
//   RNPermissions.ANDROID_PERMISSIONS.PROCESS_OUTGOING_CALLS,
// ]).then(result => {
//   console.log(result);
// });

type State = {|
  snackBarVisible: boolean,
  watchAppState: boolean,
  statuses: { [string]: PermissionStatus },
|};

export default class App extends React.Component<Props, State> {
  constructor(props: Props) {
    super(props);

    this.state = {
      snackBarVisible: false,
      watchAppState: false,
      statuses: {},
    };

    setTimeout(() => {
      this.checkAllPermissions();
    }, 2000);
  }

  componentDidMount() {
    AppState.addEventListener("change", this.onAppStateChange);
  }

  componentWillUnmount() {
    AppState.removeEventListener("change", this.onAppStateChange);
  }

  checkAllPermissions = () => {
    RNPermissions.checkMultiple(platformPermissions)
      .then(statuses => {
        console.log(statuses);
        this.setState({ statuses });
      })
      .catch(error => {
        console.error(error);
      });
  };

  onAppStateChange = (nextAppState: AppStateType) => {
    if (this.state.watchAppState && nextAppState === "active") {
      this.setState({
        snackBarVisible: true,
        watchAppState: false,
      });

      setTimeout(() => {
        // @TODO don't fire setState on unmounted component
        this.setState({ snackBarVisible: false });
      }, 3000);
    }
  };

  render() {
    return (
      <View style={styles.container}>
        <StatusBar
          backgroundColor={theme.colors.primary}
          barStyle="light-content"
        />

        <Appbar.Header>
          <Appbar.Content
            title="react-native-permissions"
            subtitle="Example application"
          />

          <Appbar.Action
            icon="settings-applications"
            onPress={() => {
              this.setState({ watchAppState: true }, () => {
                RNPermissions.openSettings();
              });
            }}
          />
        </Appbar.Header>

        <ScrollView>
          <List.Section>
            {platformPermissions.map(permission => {
              const status = this.state.statuses[permission];

              return (
                <TouchableRipple
                  key={permission}
                  disabled={
                    status === RNPermissions.RESULTS.UNAVAILABLE ||
                    status === RNPermissions.RESULTS.NEVER_ASK_AGAIN
                  }
                  onPress={() => {
                    RNPermissions.request(permission).then(status => {
                      this.setState(prevState => ({
                        ...prevState,
                        statuses: {
                          ...prevState.statuses,
                          [permission]: status,
                        },
                      }));
                    });
                  }}
                >
                  <List.Item
                    title={permission}
                    description={status}
                    right={() => (
                      <List.Icon
                        color={statusColors[status]}
                        icon={statusIcons[status]}
                      />
                    )}
                  />
                </TouchableRipple>
              );
            })}
          </List.Section>
        </ScrollView>

        <Snackbar
          onDismiss={() => this.setState({ snackBarVisible: false })}
          visible={this.state.snackBarVisible}
        >
          Welcome back ! Refreshing permissions…
        </Snackbar>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: theme.colors.background,
  },
});
