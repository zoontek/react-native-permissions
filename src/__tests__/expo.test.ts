import type {ExportedConfig} from '@expo/config-plugins';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {afterEach, beforeEach, test} from 'node:test';
import {withPermissions} from '../extras/expo.ts';

const podfile = `require File.join(File.dirname(\`node --print "require.resolve('react-native/package.json')"\`), "scripts/react_native_pods")

platform :ios, '15.1'
prepare_react_native_project!
`;

let platformProjectRoot: string;

const runIosMod = async (iosPermissions?: Parameters<typeof withPermissions>[1]): Promise<void> => {
  const config: ExportedConfig = withPermissions(
    {name: 'app', slug: 'app'},
    iosPermissions,
  ) as ExportedConfig;
  const dangerousMod = config.mods?.ios?.dangerous;
  assert.ok(dangerousMod);

  await dangerousMod({
    ...config,
    modResults: undefined,
    modRawConfig: config,
    modRequest: {
      projectRoot: path.dirname(platformProjectRoot),
      platformProjectRoot,
      modName: 'dangerous',
      platform: 'ios',
      introspect: false,
    },
  });
};

beforeEach(() => {
  platformProjectRoot = fs.mkdtempSync(path.join(os.tmpdir(), 'rnp-expo-'));
  fs.writeFileSync(path.join(platformProjectRoot, 'Podfile'), podfile);
});

afterEach(() => fs.rmSync(platformProjectRoot, {recursive: true, force: true}));

test('writes react-native-permissions.json next to the Podfile', async () => {
  await runIosMod({iosPermissions: ['Camera', 'Contacts']});

  assert.equal(
    fs.readFileSync(path.join(platformProjectRoot, 'react-native-permissions.json'), 'utf8'),
    '{\n  "ios": [\n    "Camera",\n    "Contacts"\n  ]\n}\n',
  );
  assert.match(
    fs.readFileSync(path.join(platformProjectRoot, 'Podfile'), 'utf8'),
    /setup_permissions\(\[\n {2}'Camera',\n {2}'Contacts',\n\]\)/,
  );
});

test('writes nothing when no iOS permission is listed', async () => {
  await runIosMod({iosPermissions: []});
  await runIosMod();

  assert.equal(
    fs.existsSync(path.join(platformProjectRoot, 'react-native-permissions.json')),
    false,
  );
  assert.equal(fs.readFileSync(path.join(platformProjectRoot, 'Podfile'), 'utf8'), podfile);
});

test('writes react-native-permissions.json when the project has no Podfile', async () => {
  fs.rmSync(path.join(platformProjectRoot, 'Podfile'));

  await runIosMod({iosPermissions: ['Camera']});

  assert.equal(
    fs.readFileSync(path.join(platformProjectRoot, 'react-native-permissions.json'), 'utf8'),
    '{\n  "ios": [\n    "Camera"\n  ]\n}\n',
  );
  assert.equal(fs.existsSync(path.join(platformProjectRoot, 'Podfile')), false);
});

test('deletes a stale react-native-permissions.json when no iOS permission is listed', async () => {
  const jsonPath = path.join(platformProjectRoot, 'react-native-permissions.json');

  for (const iosPermissions of [undefined, []]) {
    await runIosMod({iosPermissions: ['Camera']});
    assert.equal(fs.existsSync(jsonPath), true);

    await runIosMod(iosPermissions == null ? undefined : {iosPermissions});
    assert.equal(fs.existsSync(jsonPath), false);
  }
});

test('edits the Podfile exactly like the CocoaPods-only plugin did', async () => {
  // Output of the plugin before Swift Package Manager support (commit 4f9f820)
  const expected = `require File.join(File.dirname(\`node --print "require.resolve('react-native/package.json')"\`), "scripts/react_native_pods")
# @generated begin require - expo prebuild (DO NOT MODIFY) sync-0b3d11245f758d271ec25750612913aa85ad0f45
require File.join(File.dirname(\`node --print "require.resolve('react-native-permissions/package.json')"\`), "scripts/setup")
# @generated end require

platform :ios, '15.1'
prepare_react_native_project!
# @generated begin setup - expo prebuild (DO NOT MODIFY) sync-e86b8bdd37bd005c5d6b8201e93e692a48c8bd5d
setup_permissions([
  'Camera',
  'Contacts',
  'LocationWhenInUse',
])
# @generated end setup
`;

  await runIosMod({iosPermissions: ['Camera', 'Contacts', 'LocationWhenInUse']});

  assert.equal(fs.readFileSync(path.join(platformProjectRoot, 'Podfile'), 'utf8'), expected);
});

test('rethrows a Podfile read error other than a missing file', async () => {
  fs.rmSync(path.join(platformProjectRoot, 'Podfile'));
  fs.mkdirSync(path.join(platformProjectRoot, 'Podfile'));

  await assert.rejects(runIosMod({iosPermissions: ['Camera']}), {code: 'EISDIR'});
});
