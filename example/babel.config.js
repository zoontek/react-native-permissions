const path = require('path');
const pkg = require('../package.json');

const resolverConfig = {
  extensions: ['.ts', '.tsx', '.js', '.jsx', '.json'],
  alias: {[pkg.name]: path.resolve(__dirname, '../src')},
};

module.exports = {
  presets: ['module:@react-native/babel-preset'],
  plugins: [['module-resolver', resolverConfig]],
};
