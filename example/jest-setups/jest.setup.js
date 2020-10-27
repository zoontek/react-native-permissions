/* eslint-disable no-undef */
import {windowsAppDriverCapabilities} from 'selenium-appium';

switch (platform) {
  case 'windows':
    const webViewWindowsAppId = 'PermissionsExample_nsp2ha5jnb6xr!App';
    module.exports = {
      capabilites: windowsAppDriverCapabilities(webViewWindowsAppId),
    };
    break;
  default:
    throw 'Unknown platform: ' + platform;
}
