import {ConfigPlugin, withDangerousMod} from '@expo/config-plugins';
import {mergeContents} from '@expo/config-plugins/build/utils/generateCode';
import fs from 'fs';
import path from 'path';

type Props = {
  iosPermissions?: Array<
    | 'AppTrackingTransparency'
    | 'Bluetooth'
    | 'Calendars'
    | 'CalendarsWriteOnly'
    | 'Camera'
    | 'Contacts'
    | 'FaceID'
    | 'LocationAccuracy'
    | 'LocationAlways'
    | 'LocationWhileInUse'
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
  >;
};

const plugin: ConfigPlugin<Props> = (config, {iosPermissions}) => {
  if (iosPermissions == null || iosPermissions.length === 0) {
    return config;
  }

  return withDangerousMod(config, [
    'ios',
    async (config) => {
      const file = path.join(config.modRequest.platformProjectRoot, 'Podfile');
      let contents = await fs.promises.readFile(file, 'utf8');

      contents = mergeContents({
        tag: 'node-require-function',
        src: contents,
        newSrc: `def node_require(script)\n\t# Resolve script with node to allow for hoisting\n\trequire Pod::Executable.execute_command('node', ['-p',\n\t\t"require.resolve(\n\t\t\t'#{script}',\n\t\t\t {paths: [process.argv[1]]},\n\t\t)", __dir__]).strip\nend\n\nnode_require('react-native-permissions/scripts/setup.rb')`,
        anchor: /scripts\/react_native_pods/,
        offset: 1,
        comment: '#',
      }).contents;

      contents = mergeContents({
        tag: 'permissions-array',
        src: contents,
        newSrc: `setup_permissions([${iosPermissions
          .map((permission) => `'${permission}'`)
          .join(',')}])`,
        anchor: /prepare_react_native_project!/,
        offset: 1,
        comment: '#',
      }).contents;

      await fs.promises.writeFile(file, contents, 'utf-8');
      return config;
    },
  ]);
};

export default plugin;
