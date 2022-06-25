import * as React from 'react';
import {Alert, Platform, ScrollView, StatusBar, View} from 'react-native';
import {Appbar, Divider, List, TouchableRipple} from 'react-native-paper';
import RNPermissions, {NotificationOption, Permission, PERMISSIONS} from 'react-native-permissions';
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

export const App = () => {
  // const [notifications, setNotifications] = React.useState<NotificationsResponse>({
  //   settings: {},
  //   status: 'unavailable',
  // });

  // React.useEffect(() => {
  //   RNPermissions.checkMultiple(PERMISSIONS_VALUES)
  //     .then(setStatuses)
  //     .then(() => RNPermissions.checkNotifications())
  //     .then(setNotifications)
  //     .catch((error) => console.warn(error));
  // }, []);

  return (
    <View style={{flex: 1, backgroundColor: theme.colors.background}}>
      <StatusBar backgroundColor={theme.colors.primary} barStyle="light-content" />

      <Appbar.Header>
        <Appbar.Content title="react-native-permissions" subtitle="Example application" />

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
          const parts = item.split('.');
          const name = parts[parts.length - 1];

          return (
            <React.Fragment key={item}>
              <List.Item
                title={name}
                titleNumberOfLines={1}
                description={item}
                descriptionNumberOfLines={1}
                right={() => (
                  <View style={{flexDirection: 'row'}}>
                    <TouchableRipple
                      onPress={() => {
                        RNPermissions.check(value)
                          .then((response) => {
                            Alert.alert(`check(${name})`, JSON.stringify(response, null, 2));
                          })
                          .catch((error) => {
                            console.error(error);
                          });
                      }}
                    >
                      <List.Icon color="#90a4ae" icon="alpha-c-box" />
                    </TouchableRipple>

                    <TouchableRipple
                      onPress={() => {
                        RNPermissions.request(value)
                          .then((response) => {
                            Alert.alert(`request(${name})`, JSON.stringify(response, null, 2));
                          })
                          .catch((error) => {
                            console.error(error);
                          });
                      }}
                    >
                      <List.Icon color="#90a4ae" icon="alpha-r-box" />
                    </TouchableRipple>
                  </View>
                )}
              />

              <Divider />
            </React.Fragment>
          );
        })}

        <List.Item
          title="NOTIFICATIONS"
          titleNumberOfLines={1}
          right={() => (
            <View style={{flexDirection: 'row'}}>
              <TouchableRipple
                onPress={() => {
                  RNPermissions.checkNotifications()
                    .then((response) => {
                      Alert.alert('checkNotifications()', JSON.stringify(response, null, 2));
                    })
                    .catch((error) => {
                      console.error(error);
                    });
                }}
              >
                <List.Icon color="#90a4ae" icon="alpha-c-box" />
              </TouchableRipple>

              <TouchableRipple
                onPress={() => {
                  const options: NotificationOption[] = ['alert', 'badge', 'sound'];

                  RNPermissions.requestNotifications(options)
                    .then((response) => {
                      Alert.alert(
                        `requestNotifications([${options
                          .map((option) => `"${option}"`)
                          .join(', ')}])`,
                        JSON.stringify(response, null, 2),
                      );
                    })
                    .catch((error) => {
                      console.error(error);
                    });
                }}
              >
                <List.Icon color="#90a4ae" icon="alpha-r-box" />
              </TouchableRipple>
            </View>
          )}
        />
      </ScrollView>
    </View>
  );
};
