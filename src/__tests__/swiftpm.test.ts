import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import {afterEach, beforeEach, describe, mock, test} from 'node:test';
import {iosPermissionFrameworks, iosPermissions} from '../extras/permissions-config.ts';
import {
  createSwiftPMPlugin,
  renderPackageManifest,
  resolveIosPermissions,
  type PermissionsSource,
  type ReactDescriptor,
  type SwiftPMPluginResult,
} from '../extras/swiftpm.ts';

const libraryRoot = path.resolve(import.meta.dirname, '..', '..');

const localReact: ReactDescriptor = {
  packageRef: {
    name: 'ReactNative',
    path: '/app/ios/build/xcframeworks',
    relPath: '../../xcframeworks',
  },
  products: [
    {name: 'ReactHeaders', package: 'ReactNative'},
    {name: 'ReactNativeHeaders', package: 'ReactNative'},
    {name: 'ReactNativeDependenciesHeaders', package: 'ReactNative'},
    {name: 'ReactAppHeaders', package: 'React-GeneratedCode'},
  ],
};

const remoteReact: ReactDescriptor = {
  packageRef: {
    name: 'react-native-spm',
    url: 'https://example.com/react-native-spm.git',
    version: '0.88.0',
  },
  products: [
    {name: 'ReactHeaders', package: 'react-native-spm'},
    {name: 'ReactNativeHeaders', package: 'react-native-spm'},
    {name: 'ReactNativeDependenciesHeaders', package: 'react-native-spm'},
  ],
};

const packageJson = (ios: unknown): PermissionsSource => ({
  path: '/app/package.json',
  config: {ios},
});
const configFile = (ios: unknown): PermissionsSource => ({
  path: '/app/ios/react-native-permissions.json',
  config: {ios},
});

const warnings = (): (() => string[]) => {
  const warn = mock.method(console, 'warn', () => {});
  return () => warn.mock.calls.map((call) => String(call.arguments[0]));
};

afterEach(() => mock.restoreAll());

describe('resolveIosPermissions', () => {
  test('uses the package.json list when it is the only source', () => {
    assert.deepEqual(resolveIosPermissions({packageJson: packageJson(['Camera', 'Contacts'])}), [
      'Camera',
      'Contacts',
    ]);
  });

  test('uses react-native-permissions.json when it is the only source', () => {
    assert.deepEqual(resolveIosPermissions({configFile: configFile(['Notifications'])}), [
      'Notifications',
    ]);
  });

  test('accepts both sources when they hold the same names in any order', () => {
    const permissions = resolveIosPermissions({
      packageJson: packageJson(['Camera', 'Contacts', 'Camera']),
      configFile: configFile(['Contacts', 'Camera']),
    });

    assert.deepEqual([...permissions].sort(), ['Camera', 'Contacts']);
  });

  test('throws when both sources hold different names', () => {
    assert.throws(
      () =>
        resolveIosPermissions({
          packageJson: packageJson(['Camera', 'Contacts']),
          configFile: configFile(['Camera', 'Siri']),
        }),
      (error: Error) => {
        assert.match(error.message, /\/app\/package\.json/);
        assert.match(error.message, /\/app\/ios\/react-native-permissions\.json/);
        assert.match(error.message, /Only in \/app\/package\.json: Contacts/);
        assert.match(error.message, /Only in \/app\/ios\/react-native-permissions\.json: Siri/);
        return true;
      },
    );
  });

  test('returns an empty list and warns when no source exists', () => {
    const warned = warnings();

    assert.deepEqual(resolveIosPermissions({}), []);
    assert.equal(warned().length, 1);
    assert.match(warned()[0] ?? '', /no permission handlers will be compiled/i);
    assert.match(warned()[0] ?? '', /"react-native-permissions"/);
  });

  test('does not warn about an explicitly empty list', () => {
    const warned = warnings();

    assert.deepEqual(resolveIosPermissions({packageJson: packageJson([])}), []);
    assert.deepEqual(warned(), []);
  });

  test('throws, naming the file, when the list is not an array of strings', () => {
    assert.throws(
      () => resolveIosPermissions({packageJson: packageJson('Camera')}),
      /\/app\/package\.json/,
    );
    assert.throws(
      () => resolveIosPermissions({configFile: configFile(['Camera', 42])}),
      /\/app\/ios\/react-native-permissions\.json/,
    );
    assert.throws(
      () => resolveIosPermissions({configFile: {path: '/app/ios/x.json', config: ['Camera']}}),
      /\/app\/ios\/x\.json/,
    );
  });

  test('warns about and drops unknown names', () => {
    const warned = warnings();

    assert.deepEqual(
      resolveIosPermissions({packageJson: packageJson(['Camera', 'Foo', 'Contacts', 'Bar'])}),
      ['Camera', 'Contacts'],
    );
    assert.deepEqual(warned(), ['[Permissions] Unknown permissions: Foo, Bar']);
  });
});

describe('permissions config', () => {
  test('lists every handler folder in ios/', () => {
    const folders = fs
      .readdirSync(path.join(libraryRoot, 'ios'), {withFileTypes: true})
      .filter((entry) => entry.isDirectory() && !entry.name.endsWith('.xcodeproj'))
      .map((entry) => entry.name);

    assert.deepEqual([...iosPermissions].sort(), folders.sort());
  });

  test('matches the frameworks map in scripts/setup.rb', () => {
    const setup = fs.readFileSync(path.join(libraryRoot, 'scripts', 'setup.rb'), 'utf8');
    const setupFrameworks: Record<string, string[]> = {};

    for (const line of setup.split('\n')) {
      const entry = /^\s*'(\w+)' => \[(.*)\],?$/.exec(line);

      if (entry?.[1] != null && entry[2] != null) {
        setupFrameworks[entry[1]] = entry[2].split(', ').map((name) => name.replace(/'/g, ''));
      }
    }

    assert.deepEqual(setupFrameworks, iosPermissionFrameworks);
  });
});

const cameraNotificationsContactsManifest = `// swift-tools-version: 6.0
// Generated by react-native-permissions. Do not edit: it is rewritten on every SwiftPM sync.

import PackageDescription

let package = Package(
    name: "RNPermissions",
    platforms: [.iOS("15.1")],
    products: [
        .library(name: "RNPermissions", targets: ["RNPermissions"]),
    ],
    dependencies: [
        .package(name: "ReactNative", path: "/app/ios/build/xcframeworks"),
        .package(name: "React-GeneratedCode", path: "/app/ios/build/generated/ios"),
    ],
    targets: [
        .target(
            name: "RNPermissions",
            dependencies: [
                .product(name: "ReactHeaders", package: "ReactNative"),
                .product(name: "ReactNativeHeaders", package: "ReactNative"),
                .product(name: "ReactNativeDependenciesHeaders", package: "ReactNative"),
                .product(name: "ReactAppHeaders", package: "React-GeneratedCode"),
                "RNPermissionsSwift",
            ],
            path: ".",
            exclude: [
                "root/Contacts/RNPermissionsContactPicker.swift",
            ],
            sources: [
                "root/RNPermissions.mm",
                "root/Camera",
                "root/Contacts",
                "root/Notifications",
            ],
            resources: [.copy("root/PrivacyInfo.xcprivacy")],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("root"),
                .headerSearchPath("root/Camera"),
                .headerSearchPath("root/Contacts"),
                .headerSearchPath("root/Notifications"),
                .define("RCT_NEW_ARCH_ENABLED"),
            ],
            cxxSettings: [
                .headerSearchPath("root"),
                .headerSearchPath("root/Camera"),
                .headerSearchPath("root/Contacts"),
                .headerSearchPath("root/Notifications"),
                .define("RCT_NEW_ARCH_ENABLED"),
                .define("DEBUG", .when(configuration: .debug)),
                .define("NDEBUG", .when(configuration: .release)),
            ],
            linkerSettings: [
                .linkedFramework("AVFoundation"),
                .linkedFramework("Contacts"),
                .linkedFramework("ContactsUI"),
                .linkedFramework("UserNotifications"),
            ]
        ),
        .target(
            name: "RNPermissionsSwift",
            path: "root",
            sources: [
                "Contacts/RNPermissionsContactPicker.swift",
            ],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ],
    cxxLanguageStandard: .cxx20
)
`;

describe('renderPackageManifest', () => {
  test('renders only the chosen handlers and their frameworks', () => {
    const manifest = renderPackageManifest({
      permissions: ['Camera', 'Notifications', 'Contacts'],
      react: localReact,
      codegenPackagePath: '/app/ios/build/generated/ios',
    });

    assert.equal(manifest, cameraNotificationsContactsManifest);
  });

  test('renders the module alone when no permission is chosen', () => {
    const manifest = renderPackageManifest({
      permissions: [],
      react: localReact,
      codegenPackagePath: '/app/ios/build/generated/ios',
    });

    assert.match(manifest, /sources: \[\n {16}"root\/RNPermissions\.mm",\n {12}\],/);
    assert.match(manifest, /resources: \[\.copy\("root\/PrivacyInfo\.xcprivacy"\)\]/);
    assert.doesNotMatch(manifest, /headerSearchPath\("root\/\w+"\)/);
    assert.doesNotMatch(manifest, /linkerSettings|linkedFramework/);
    assert.doesNotMatch(manifest, /RNPermissionsSwift|exclude:/);
  });

  test('renders frameworks deduplicated and sorted', () => {
    const manifest = renderPackageManifest({
      permissions: ['Microphone', 'Camera', 'Reminders', 'Calendars'],
      react: localReact,
      codegenPackagePath: null,
    });

    assert.equal(
      manifest.match(/\.linkedFramework\("\w+"\)/g)?.join(' '),
      '.linkedFramework("AVFoundation") .linkedFramework("EventKit")',
    );
  });

  test('depends on a remote React package without React-GeneratedCode', () => {
    const manifest = renderPackageManifest({
      permissions: ['Camera'],
      react: remoteReact,
      codegenPackagePath: null,
    });

    assert.match(
      manifest,
      /dependencies: \[\n {8}\.package\(url: "https:\/\/example\.com\/react-native-spm\.git", exact: "0\.88\.0"\),\n {4}\],/,
    );
    assert.match(manifest, /\.product\(name: "ReactHeaders", package: "react-native-spm"\)/);
    assert.doesNotMatch(manifest, /React-GeneratedCode|ReactAppHeaders/);
  });

  test('omits React-GeneratedCode when its package is absent', () => {
    const manifest = renderPackageManifest({
      permissions: ['Camera'],
      react: localReact,
      codegenPackagePath: null,
    });

    assert.doesNotMatch(manifest, /\.package\(name: "React-GeneratedCode"/);
  });

  test('renders no React dependency when React is not resolvable', () => {
    const manifest = renderPackageManifest({
      permissions: ['Camera'],
      react: null,
      codegenPackagePath: null,
    });

    assert.doesNotMatch(manifest, /\.package\(|\.product\(/);
  });

  test('escapes paths as valid Swift string literals', () => {
    const manifest = renderPackageManifest({
      permissions: ['Camera'],
      react: localReact,
      codegenPackagePath: '/a "b"\\c\nd\te\u0001f\bg\fh\u007Fi é',
    });

    assert.ok(
      manifest.includes(
        '.package(name: "React-GeneratedCode", path: "/a \\"b\\"\\\\c\\nd\\te\\u{1}f\\u{8}g\\u{C}h\\u{7F}i é")',
      ),
    );
  });

  test('moves every Swift file of a chosen folder to the Swift target', () => {
    const manifest = renderPackageManifest({
      permissions: iosPermissions,
      react: localReact,
      codegenPackagePath: null,
    });

    for (const permission of iosPermissions) {
      const folder = path.join(libraryRoot, 'ios', permission);

      for (const file of fs.readdirSync(folder).filter((name) => name.endsWith('.swift'))) {
        assert.ok(manifest.includes(`"root/${permission}/${file}",`), `${file} not excluded`);
        assert.ok(manifest.includes(`"${permission}/${file}",`), `${file} not in Swift target`);
      }
    }
  });
});

describe('SwiftPM autolinking plugin', () => {
  let projectRoot: string;
  let appRoot: string;
  let outputDir: string;
  let packageDir: string;

  const writePackageJson = (ios: string[]): void =>
    fs.writeFileSync(
      path.join(projectRoot, 'package.json'),
      JSON.stringify({name: 'app', 'react-native-permissions': {ios}}),
    );

  const runPlugin = (): SwiftPMPluginResult =>
    createSwiftPMPlugin(libraryRoot)({appRoot, projectRoot, outputDir, react: localReact});

  beforeEach(() => {
    projectRoot = fs.realpathSync(fs.mkdtempSync(path.join(os.tmpdir(), 'rnp-swiftpm-')));
    appRoot = path.join(projectRoot, 'ios');
    outputDir = path.join(appRoot, 'build', 'generated', 'autolinking');
    packageDir = path.join(outputDir, 'react-native-permissions', 'RNPermissions');

    fs.mkdirSync(outputDir, {recursive: true});
    fs.mkdirSync(path.join(appRoot, 'build', 'generated', 'ios'));
    fs.writeFileSync(path.join(appRoot, 'build', 'generated', 'ios', 'Package.swift'), '');
    writePackageJson(['Camera']);
  });

  afterEach(() => fs.rmSync(projectRoot, {recursive: true, force: true}));

  test('writes the package and returns its dependencies', () => {
    const result = runPlugin();

    assert.deepEqual(result, {
      packageDependencies: [{name: 'RNPermissions', path: packageDir}],
      productDependencies: [{name: 'RNPermissions', package: 'RNPermissions'}],
      watchPaths: [
        path.join(projectRoot, 'package.json'),
        path.join(appRoot, 'react-native-permissions.json'),
      ],
    });
    assert.ok(result.watchPaths.every((watchPath) => path.isAbsolute(watchPath)));

    assert.equal(
      fs.readFileSync(path.join(packageDir, 'Package.swift'), 'utf8'),
      renderPackageManifest({
        permissions: ['Camera'],
        react: localReact,
        codegenPackagePath: path.join(appRoot, 'build', 'generated', 'ios'),
      }),
    );
    assert.equal(fs.readlinkSync(path.join(packageDir, 'root')), path.join(libraryRoot, 'ios'));
    assert.ok(fs.statSync(path.join(packageDir, 'include')).isDirectory());
  });

  test('reads the list from react-native-permissions.json in the app root', () => {
    fs.writeFileSync(path.join(projectRoot, 'package.json'), JSON.stringify({name: 'app'}));
    fs.writeFileSync(
      path.join(appRoot, 'react-native-permissions.json'),
      JSON.stringify({ios: ['Siri']}),
    );

    runPlugin();

    assert.match(fs.readFileSync(path.join(packageDir, 'Package.swift'), 'utf8'), /"root\/Siri"/);
  });

  test('throws, naming the file, when react-native-permissions.json is not valid JSON', () => {
    const configPath = path.join(appRoot, 'react-native-permissions.json');
    fs.writeFileSync(configPath, '{"ios": [');

    assert.throws(runPlugin, (error: Error) => error.message.includes(configPath));
  });

  test('leaves an unchanged package untouched on the next run', () => {
    runPlugin();

    const manifestPath = path.join(packageDir, 'Package.swift');
    const rootPath = path.join(packageDir, 'root');
    const past = new Date('2020-01-01T00:00:00Z');
    fs.utimesSync(manifestPath, past, past);
    const rootInode = fs.lstatSync(rootPath).ino;

    runPlugin();

    assert.equal(fs.statSync(manifestPath).mtime.getTime(), past.getTime());
    assert.equal(fs.lstatSync(rootPath).ino, rootInode);
  });

  test('rewrites the package when the list changes', () => {
    runPlugin();
    writePackageJson(['Camera', 'Motion']);
    runPlugin();

    assert.match(
      fs.readFileSync(path.join(packageDir, 'Package.swift'), 'utf8'),
      /\.linkedFramework\("CoreMotion"\)/,
    );
  });

  test('repoints a root symlink that points elsewhere', () => {
    runPlugin();

    const rootPath = path.join(packageDir, 'root');
    fs.unlinkSync(rootPath);
    fs.symlinkSync(os.tmpdir(), rootPath);

    runPlugin();

    assert.equal(fs.readlinkSync(rootPath), path.join(libraryRoot, 'ios'));
  });
});
