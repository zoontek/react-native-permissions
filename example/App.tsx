import * as React from 'react';
import {Platform, ScrollView, StatusBar, View} from 'react-native';
import {Appbar, Button, Divider, Snackbar, Text} from 'react-native-paper';
import RNPermissions, {NotificationOption, Permission, PERMISSIONS} from 'react-native-permissions';

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

export const App = () => {
  const [snackbarContent, setSnackbarContent] = React.useState<string>();

  const showSnackbar = (title: string, response: unknown) =>
    setSnackbarContent(title + '\n\n' + JSON.stringify(response, null, 2));

  const hideSnackbar = () => setSnackbarContent(undefined);

  return (
    <View style={{flex: 1}}>
      <StatusBar barStyle="dark-content" />

      <Appbar.Header>
        <Appbar.Content title="Permissions app" />

        {Platform.OS === 'ios' && (
          <Appbar.Action
            icon="image-multiple"
            onPress={() => {
              RNPermissions.openLimitedPhotoLibraryPicker().catch((error) => {
                console.error(error);
              });
            }}
          />
        )}

        {Platform.OS === 'ios' && (
          <Appbar.Action
            icon="crosshairs-question"
            onPress={() => {
              RNPermissions.requestLocationAccuracy({
                purposeKey: 'full-accuracy',
              }).then((accuracy) => {
                console.warn({accuracy});
              });
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
          const parts = item.split('.');
          const name = parts[parts.length - 1];

          return (
            <React.Fragment key={item}>
              <View style={{padding: 20}}>
                <Text numberOfLines={1} variant="bodyMedium">
                  {name}
                </Text>

                <View style={{flexDirection: 'row', marginTop: 12}}>
                  <Button
                    icon="eye-outline"
                    mode="contained"
                    onPress={() => {
                      RNPermissions.check(value)
                        .then((status) => {
                          showSnackbar(`check(${name})`, status);
                        })
                        .catch((error) => {
                          console.error(error);
                        });
                    }}
                  >
                    Check
                  </Button>

                  <View style={{width: 8}} />

                  <Button
                    icon="help-circle-outline"
                    mode="contained"
                    onPress={() => {
                      RNPermissions.request(value)
                        .then((status) => {
                          showSnackbar(`request(${name})`, status);
                        })
                        .catch((error) => {
                          console.error(error);
                        });
                    }}
                  >
                    Request
                  </Button>
                </View>
              </View>

              <Divider />
            </React.Fragment>
          );
        })}

        <View style={{padding: 20, paddingBottom: 32}}>
          <Text numberOfLines={1} variant="bodyMedium">
            NOTIFICATIONS
          </Text>

          <View style={{flexDirection: 'row', marginTop: 12}}>
            <Button
              icon="eye-outline"
              mode="contained"
              onPress={() => {
                RNPermissions.checkNotifications()
                  .then((response) => {
                    showSnackbar('checkNotifications()', response);
                  })
                  .catch((error) => {
                    console.error(error);
                  });
              }}
            >
              Check
            </Button>

            <View style={{width: 8}} />

            <Button
              icon="help-circle-outline"
              mode="contained"
              onPress={() => {
                const options: NotificationOption[] = ['alert', 'badge', 'sound'];

                RNPermissions.requestNotifications(options)
                  .then((response) => {
                    showSnackbar(
                      `requestNotifications([${options
                        .map((option) => `"${option}"`)
                        .join(', ')}])`,
                      response,
                    );
                  })
                  .catch((error) => {
                    console.error(error);
                  });
              }}
            >
              Request
            </Button>
          </View>
        </View>
      </ScrollView>

      <Snackbar
        visible={snackbarContent != null}
        duration={10000}
        onDismiss={hideSnackbar}
        action={{
          label: 'Hide',
          onPress: hideSnackbar,
        }}
      >
        {snackbarContent}
      </Snackbar>
    </View>
  );
};
