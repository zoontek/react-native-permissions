import {driver, By2} from 'selenium-appium';
import {until} from 'selenium-webdriver';

const setup = require('../jest-setups/jest.setup');
jest.setTimeout(50000);

beforeAll(() => {
  return driver.startWithCapabilities(setup.capabilites);
});

afterAll(() => {
  return driver.quit();
});

describe('Test App', () => {
  test('Permissions present', async () => {
    await driver.wait(
      until.elementLocated(By2.nativeName('CODE_GENERATION:granted')),
    );
    await driver.wait(
      until.elementLocated(By2.nativeName('DOCUMENTS_LIBRARY:unavailable')),
    );
    await driver.wait(until.elementLocated(By2.nativeName('CONTACTS:denied')));
    await driver.wait(until.elementLocated(By2.nativeName('LOCATION:blocked')));
  });
});
