import {ConfigPlugin, createRunOncePlugin, withDangerousMod} from '@expo/config-plugins';
import {mergeContents} from '@expo/config-plugins/build/utils/generateCode';
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

const withPermissions: ConfigPlugin<Props> = (config, {iosPermissions = []}) =>
  withDangerousMod(config, [
    'ios',
    async (config) => {
      const file = path.join(config.modRequest.platformProjectRoot, 'Podfile');
      const contents = await fs.readFile(file, 'utf8');

      if (iosPermissions.length === 0) {
        return config;
      }

      const withRequire = mergeContents({
        tag: 'require',
        src: contents,
        anchor:
          /^require File\.join\(File\.dirname\(`node --print "require\.resolve\('react-native\/package\.json'\)"`\), "scripts\/react_native_pods"\)$/m,
        newSrc: `require File.join(File.dirname(\`node --print "require.resolve('react-native-permissions/package.json')"\`), "scripts/setup")`,
        offset: 1,
        comment: '#',
      });

      const withSetup = mergeContents({
        tag: 'setup',
        src: withRequire.contents,
        anchor: /^prepare_react_native_project!$/m,
        newSrc: `setup_permissions([
${iosPermissions.map((permission) => `  '${permission}',`).join('\n')}
])`,
        offset: 1,
        comment: '#',
      });

      await fs.writeFile(file, withSetup.contents, 'utf-8');
      return config;
    },
  ]);

export default createRunOncePlugin(withPermissions, 'react-native-permissions');
