const {existsSync} = require('fs');
const fs = require('fs/promises');
const path = require('path');
const pc = require('picocolors');
const pkgDir = require('pkg-dir');

const CONFIG_KEY = 'reactNativePermissionsIOS';

const log = {
  error: (text) => console.log(pc.red(text)),
  warning: (text) => console.log(pc.yellow(text)),
};

module.exports = {
  commands: [
    {
      name: 'setup-ios-permissions',
      description:
        'Update react-native-permissions podspec to link additional permission handlers.',
      func: async () => {
        const rootDir = pkgDir.sync() || process.cwd();
        const pkgPath = path.join(rootDir, 'package.json');
        const pkg = await fs.readFile(pkgPath, 'utf-8');
        const jsonPath = path.join(rootDir, `${CONFIG_KEY}.json`);

        let config = JSON.parse(pkg)[CONFIG_KEY];

        if (!config && existsSync(jsonPath)) {
          const text = await fs.readFile(jsonPath, 'utf-8');
          config = JSON.parse(text);
        }

        if (!config) {
          log.error(
            `No config detected. In order to setup iOS permissions, you first need to add an "${CONFIG_KEY}" array in your package.json.`,
          );

          process.exit(1);
        }

        if (!Array.isArray(config) || config.length === 0) {
          log.error(`Invalid "${CONFIG_KEY}" config detected. It must be a non-empty array.`);
          process.exit(1);
        }

        const iosDirPath = path.join(__dirname, 'ios');
        const podspecPath = path.join(__dirname, 'RNPermissions.podspec');
        const iosDir = await fs.readdir(iosDirPath, {withFileTypes: true});
        const podspec = await fs.readFile(podspecPath, 'utf-8');

        const directories = iosDir
          .filter((dirent) => dirent.isDirectory() || dirent.name.endsWith('.xcodeproj'))
          .map((dirent) => dirent.name)
          .filter((name) => config.includes(name));

        const unknownPermissions = config
          .filter((name) => !directories.includes(name))
          .map((name) => `"${name}"`);

        if (unknownPermissions.length > 0) {
          log.warning(`Unknown iOS permissions: ${unknownPermissions.join(', ')}`);
        }

        const sourceFiles = [
          '"ios/*.{h,m,mm}"',
          ...directories.map((name) => `"ios/${name}/*.{h,m,mm}"`),
        ];

        const podspecContent = podspec.replace(/"ios\/\*\.{h,m,mm}".*/, sourceFiles.join(', '));
        return fs.writeFile(podspecPath, podspecContent, 'utf-8');
      },
    },
  ],
};
