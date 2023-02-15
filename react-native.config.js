const cosmiconfig = require('cosmiconfig');
const fs = require('fs/promises');
const path = require('path');
const pc = require('picocolors');

// TODO: Improve wording (description, errors)

module.exports = {
  commands: [
    {
      name: 'setup-ios-permissions',
      description: 'No description',
      func: async () => {
        const explorer = await cosmiconfig('iosPermissions');
        const result = await explorer.search();

        if (!result) {
          console.log(pc.red('No config detected'));
          process.exit(1);
        }

        const {config} = result;

        if (!Array.isArray(config)) {
          console.log(pc.red('Invalid config'));
          process.exit(1);
        }

        if (config.length === 0) {
          console.log(pc.yellow('Empty config'));
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
          console.log(pc.yellow(`Unknown permissions: ${unknownPermissions.join(', ')}`));
        }

        const sourceFiles = [
          '"ios/*.{h,m}"',
          ...directories.map((name) => `"ios/${name}/*.{h,m}"`),
        ];

        const podspecContent = podspec.replace(/"ios\/\*\.{h,m}".*/, sourceFiles.join(', '));
        return fs.writeFile(podspecPath, podspecContent, 'utf-8');
      },
    },
  ],
};
