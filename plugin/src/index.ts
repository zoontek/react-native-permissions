import {ConfigPlugin, withDangerousMod} from '@expo/config-plugins';
import {mergeContents} from '@expo/config-plugins/build/utils/generateCode';
import {promises} from 'fs';
import path from 'path';

export function addPodfileNodeRequire(src: string): string {
  return mergeContents({
    tag: `node-require-function`,
    src,
    newSrc: `def node_require(script)\n\t# Resolve script with node to allow for hoisting\n\trequire Pod::Executable.execute_command('node', ['-p',\n\t\t"require.resolve(\n\t\t\t'#{script}',\n\t\t\t {paths: [process.argv[1]]},\n\t\t)", __dir__]).strip\nend\n\nnode_require('react-native-permissions/scripts/setup.rb')`,
    anchor: /scripts\/react_native_pods/,
    offset: 1,
    comment: '#',
  }).contents;
}

export function addPodfilePermissionsArray(src: string, permissions: string[]): string {
  return mergeContents({
    tag: `permissions-array`,
    src,
    newSrc: `setup_permissions([${permissions.map((p) => `'${p}'`).join(',')}])`,
    anchor: /prepare_react_native_project!/,
    offset: 1,
    comment: '#',
  }).contents;
}

export type IOSPermission =
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
  | 'StoreKit';

export interface IOSPermissions {
  /**
   * Array of iOS permissions for which to setup permissions.
   */
  iosPermissions: IOSPermission[];
}

const withIOSPodfilePermissions: ConfigPlugin<IOSPermissions> = (config, {iosPermissions}) => {
  if (!iosPermissions || iosPermissions.length === 0) {
    return config;
  }

  return withDangerousMod(config, [
    'ios',
    async (c) => {
      const file = path.join(c.modRequest.platformProjectRoot, 'Podfile');

      let contents = await promises.readFile(file, 'utf8');

      contents = addPodfileNodeRequire(contents);
      contents = addPodfilePermissionsArray(contents, iosPermissions);

      await promises.writeFile(file, contents, 'utf-8');
      return c;
    },
  ]);
};

export default withIOSPodfilePermissions;
