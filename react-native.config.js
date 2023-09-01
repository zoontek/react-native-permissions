const path = require('path');
const fs = require('fs');

const CONFIG_KEY = 'reactNativePermissionsIOS';

const pkgDir = (dir) => {
  const pkgPath = path.join(dir, 'package.json');

  if (fs.existsSync(pkgPath)) {
    return dir;
  }

  const parentDir = path.resolve(dir, '..');

  if (parentDir !== dir) {
    return pkgDir(parentDir);
  }
};

const logError = (message) => {
  console.log(`\x1b[31m${message}\x1b[0m`);
};

const logWarning = (message) => {
  console.log(`\x1b[33m${message}\x1b[0m`);
};

module.exports = {
  commands: [
    {
      name: 'setup-ios-permissions',
      description:
        'Update react-native-permissions podspec to link additional permission handlers.',
      func: () => {
        const rootDir = pkgDir(process.cwd()) || process.cwd();
        const pkgPath = path.join(rootDir, 'package.json');
        const jsonPath = path.join(rootDir, `${CONFIG_KEY}.json`);

        let config = JSON.parse(fs.readFileSync(pkgPath, 'utf-8'))[CONFIG_KEY];

        if (!config && fs.existsSync(jsonPath)) {
          const text = fs.readFileSync(jsonPath, 'utf-8');
          config = JSON.parse(text);
        }

        if (!config) {
          logError(`No ${CONFIG_KEY} config found`);
          process.exit(1);
        }

        if (!Array.isArray(config)) {
          logError(`Invalid ${CONFIG_KEY} config`);
          process.exit(1);
        }

        const iosDir = path.join(__dirname, 'ios');
        const iosDirents = fs.readdirSync(iosDir, {withFileTypes: true});

        const directories = iosDirents
          .filter((dirent) => dirent.isDirectory() || dirent.name.endsWith('.xcodeproj'))
          .map((dirent) => dirent.name)
          .filter((name) => config.includes(name));

        const sourceFiles = [
          '"ios/*.{h,m,mm}"',
          ...directories.map((name) => `"ios/${name}/*.{h,m,mm}"`),
        ];

        const unknownPermissions = config.filter((name) => !directories.includes(name));

        if (unknownPermissions.length > 0) {
          logWarning(`Unknown permissions: ${unknownPermissions.join(', ')}`);
        }

        const podspecPath = path.join(__dirname, 'RNPermissions.podspec');
        const podspec = fs.readFileSync(podspecPath, 'utf-8');
        const podspecContent = podspec.replace(/"ios\/\*\.{h,m,mm}".*/, sourceFiles.join(', '));

        fs.writeFileSync(podspecPath, podspecContent, 'utf-8');
      },
    },
  ],
};
