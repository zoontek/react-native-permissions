import {
  CodeGenerator,
  createRunOncePlugin,
  withDangerousMod,
  type ConfigPlugin,
  type ExportedConfigWithProps,
} from '@expo/config-plugins';
import {existsSync} from 'node:fs';
import {readFile, rm, writeFile} from 'node:fs/promises';
import {join} from 'node:path';
import type {IosPermission} from './swiftpm';

type PermissionsPluginConfig = {
  /**
   * iOS permissions to add to the Podfile (`setup_permissions`)
   * and to `ios/permissions.json` (Swift Package Manager)
   */
  iosPermissions?: IosPermission[];
};

const plugin: ConfigPlugin<Partial<PermissionsPluginConfig> | undefined> = (
  expoConfig,
  {iosPermissions} = {},
) =>
  withDangerousMod(expoConfig, [
    'ios',
    async (config): Promise<ExportedConfigWithProps<unknown>> => {
      const {platformProjectRoot} = config.modRequest;
      const swiftPmFilePath = join(platformProjectRoot, 'permissions.json');

      if (iosPermissions == null || iosPermissions.length === 0) {
        await rm(swiftPmFilePath, {force: true});
        return config;
      }

      await writeFile(swiftPmFilePath, JSON.stringify(iosPermissions, null, 2) + '\n', 'utf-8');

      const filePath = join(platformProjectRoot, 'Podfile');

      if (!existsSync(filePath)) {
        return config;
      }

      const contents = await readFile(filePath, 'utf8');

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
