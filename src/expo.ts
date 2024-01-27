import {ConfigPlugin, withDangerousMod} from '@expo/config-plugins';
import * as fs from 'fs/promises';
import * as path from 'path';

type Props = {
  iosPermissions?: (
    | 'AppTrackingTransparency'
    | 'Bluetooth'
    | 'Calendars'
    | 'CalendarsWriteOnly'
    | 'Camera'
    | 'Contacts'
    | 'FaceID'
    | 'LocationAccuracy'
    | 'LocationAlways'
    | 'LocationWhenInUse'
    | 'MediaLibrary'
    | 'Microphone'
    | 'Motion'
    | 'Notifications'
    | 'PhotoLibrary'
    | 'PhotoLibraryAddOnly'
    | 'Reminders'
    | 'Siri'
    | 'SpeechRecognition'
    | 'StoreKit'
  )[];
};

const requireRegExp =
  /require Pod::Executable\.execute_command\('node', \['-p',\s*'require\.resolve\(\s*"react-native\/scripts\/react_native_pods\.rb",\s*{paths: \[process\.argv\[1\]]},\s*\)', __dir__\]\)\.strip/;

const prepareRegExp = /prepare_react_native_project!/;

const withPermissions: ConfigPlugin<Props> = (config, {iosPermissions = []}) =>
  withDangerousMod(config, [
    'ios',
    async (config) => {
      const file = path.join(config.modRequest.platformProjectRoot, 'Podfile');
      const contents = await fs.readFile(file, 'utf8');

      if (iosPermissions.length === 0) {
        return config;
      }
      if (!requireRegExp.test(contents) || !prepareRegExp.test(contents)) {
        console.error(
          "ERROR: Cannot add react-native-permissions to the project's ios/Podfile because it's malformed. Please report this with a copy of your project Podfile.",
        );
        return config;
      }

      const nodeRequire = `
def node_require(script)
  # Resolve script with node to allow for hoisting
  require Pod::Executable.execute_command('node', ['-p',
    "require.resolve(
      '#{script}',
      {paths: [process.argv[1]]},
    )", __dir__]).strip
end

node_require('react-native/scripts/react_native_pods.rb')
node_require('react-native-permissions/scripts/setup.rb')
`.trim();

      const setupFunction = `
prepare_react_native_project!

setup_permissions([
  ${iosPermissions.map((permission) => `  '${permission}'`).join(',\n')}
])
`.trim();

      await fs.writeFile(
        file,
        contents.replace(requireRegExp, nodeRequire).replace(prepareRegExp, setupFunction),
        'utf-8',
      );

      return config;
    },
  ]);

export default withPermissions;
