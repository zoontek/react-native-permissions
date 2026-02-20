import {type ConfigPlugin, createRunOncePlugin, withDangerousMod} from '@expo/config-plugins';
import {mergeContents} from '@expo/config-plugins/build/utils/generateCode';
import {readFile, writeFile} from 'fs/promises';
import {join} from 'path';

type PermissionsPluginConfig = {
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

const plugin: ConfigPlugin<Partial<PermissionsPluginConfig> | undefined> = (
  expoConfig,
  {iosPermissions} = {},
) =>
  withDangerousMod(expoConfig, [
    'ios',
    async (config) => {
      if (iosPermissions == null || iosPermissions.length === 0) {
        return config;
      }

      const filePath = join(config.modRequest.platformProjectRoot, 'Podfile');
      const contents = await readFile(filePath, 'utf8');

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

      await writeFile(filePath, withSetup.contents, 'utf-8');
      return config;
    },
  ]);

const PACKAGE_NAME = 'react-native-permissions';

export const withPermissions = createRunOncePlugin(plugin, PACKAGE_NAME);

export default (
  config: PermissionsPluginConfig,
): [typeof PACKAGE_NAME, PermissionsPluginConfig] => [PACKAGE_NAME, config];
