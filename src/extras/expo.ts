import {
  CodeGenerator,
  createRunOncePlugin,
  withDangerousMod,
  type ConfigPlugin,
  type ExportedConfigWithProps,
} from '@expo/config-plugins';
import {readFile, rm, writeFile} from 'node:fs/promises';
import {join} from 'node:path';
import type {IosPermission} from './permissions-config';

type PermissionsPluginConfig = {
  /**
   * List of iOS permissions to add in the Podfile via `setup_permissions`,
   * and in `ios/react-native-permissions.json` for Swift Package Manager
   */
  iosPermissions?: IosPermission[];
};

const readPodfile = async (filePath: string): Promise<string | undefined> => {
  try {
    return await readFile(filePath, 'utf8');
  } catch (error) {
    if ((error as NodeJS.ErrnoException).code === 'ENOENT') {
      return undefined;
    }
    throw error;
  }
};

const plugin: ConfigPlugin<Partial<PermissionsPluginConfig> | undefined> = (
  expoConfig,
  {iosPermissions} = {},
) =>
  withDangerousMod(expoConfig, [
    'ios',
    async (config): Promise<ExportedConfigWithProps<unknown>> => {
      const {platformProjectRoot} = config.modRequest;
      const swiftPmFilePath = join(platformProjectRoot, 'react-native-permissions.json');

      if (iosPermissions == null || iosPermissions.length === 0) {
        await rm(swiftPmFilePath, {force: true});
        return config;
      }

      await writeFile(
        swiftPmFilePath,
        JSON.stringify({ios: iosPermissions}, null, 2) + '\n',
        'utf-8',
      );

      const filePath = join(platformProjectRoot, 'Podfile');
      const contents = await readPodfile(filePath);

      if (contents == null) {
        return config;
      }

      const withRequire = CodeGenerator.mergeContents({
        tag: 'require',
        src: contents,
        anchor:
          /^require File\.join\(File\.dirname\(`node --print "require\.resolve\('react-native\/package\.json'\)"`\), "scripts\/react_native_pods"\)$/m,
        newSrc: `require File.join(File.dirname(\`node --print "require.resolve('react-native-permissions/package.json')"\`), "scripts/setup")`,
        offset: 1,
        comment: '#',
      });

      const withSetup = CodeGenerator.mergeContents({
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
