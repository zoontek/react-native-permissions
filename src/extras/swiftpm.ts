import fs from 'node:fs';
import path from 'node:path';

// Keep in sync with `permissions_frameworks` in scripts/setup.rb
export const iosPermissionFrameworks = {
  AppTrackingTransparency: ['AdSupport', 'AppTrackingTransparency'],
  Bluetooth: ['CoreBluetooth'],
  Calendars: ['EventKit'],
  CalendarsWriteOnly: ['EventKit'],
  Camera: ['AVFoundation'],
  Contacts: ['Contacts', 'ContactsUI'],
  FaceID: ['LocalAuthentication'],
  LocationAccuracy: ['CoreLocation'],
  LocationAlways: ['CoreLocation'],
  LocationWhenInUse: ['CoreLocation'],
  MediaLibrary: ['MediaPlayer'],
  Microphone: ['AVFoundation'],
  Motion: ['CoreMotion'],
  Notifications: ['UserNotifications'],
  PhotoLibrary: ['Photos', 'PhotosUI'],
  PhotoLibraryAddOnly: ['Photos'],
  Reminders: ['EventKit'],
  Siri: ['Intents'],
  SpeechRecognition: ['Speech'],
  StoreKit: ['StoreKit'],
} as const satisfies Record<string, readonly string[]>;

export type IosPermission = keyof typeof iosPermissionFrameworks;

export const iosPermissions = Object.keys(iosPermissionFrameworks) as IosPermission[];

const isIosPermission = (name: string): name is IosPermission =>
  (iosPermissions as readonly string[]).includes(name);

type PackageRef = {name: string} & (
  {path: string; relPath?: string} | {url: string; version: string}
);

type ProductRef = {
  name: string;
  package: string;
};

// React Native's `context.react`
export type ReactDescriptor = {
  packageRef: PackageRef;
  products: ProductRef[];
};

// The fields of React Native's plugin context used here
type SwiftPMPluginContext = {
  appRoot: string;
  outputDir: string;
  react: ReactDescriptor | null;
};

type SwiftPMPluginResult = {
  packageDependencies: {name: string; path: string}[];
  productDependencies: ProductRef[];
  watchPaths: string[];
};

const CODEGEN_PACKAGE_NAME = 'React-GeneratedCode';
const CONFIG_FILE_NAME = 'permissions.json';
const NPM_PACKAGE_NAME = 'react-native-permissions';
const PACKAGE_NAME = 'RNPermissions';
const SWIFT_TARGET_NAME = 'RNPermissionsSwift';

// SwiftPM can't mix Swift and Objective-C in one target, so these get a separate one
const swiftSources: Partial<Record<IosPermission, readonly string[]>> = {
  Contacts: ['RNPermissionsContactPicker.swift'],
};

const unique = <T>(items: readonly T[]): T[] =>
  items.filter((item, index) => items.indexOf(item) === index);

// Reads `ios/permissions.json`, written by hand or by the Expo config plugin
export const readIosPermissions = (filePath: string): IosPermission[] => {
  if (!fs.existsSync(filePath)) {
    console.warn(
      `[Permissions] No iOS permissions configured, so no permission handlers will be compiled. List them in ios/${CONFIG_FILE_NAME}, like ["Camera"], or with the "iosPermissions" option of the Expo config plugin.`,
    );

    return [];
  }

  let config: unknown;

  try {
    config = JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    if (error instanceof Error) {
      error.message = `[Permissions] Could not read ${filePath}: ${error.message}`;
    }

    throw error;
  }

  if (!Array.isArray(config) || !config.every((name) => typeof name === 'string')) {
    throw new Error(
      `[Permissions] Invalid iOS permissions in ${filePath}: expected an array of permission names, like ["Camera", "Notifications"].`,
    );
  }

  const names = unique(config);
  const unknownNames = names.filter((name) => !isIosPermission(name));

  if (unknownNames.length > 0) {
    console.warn(`[Permissions] Unknown permissions: ${unknownNames.join(', ')}`);
  }

  return names.filter(isIosPermission);
};

const swiftEscapes: Record<string, string> = {
  '\\': '\\\\',
  '"': '\\"',
  '\n': '\\n',
  '\r': '\\r',
  '\t': '\\t',
};

const escapeSwiftCharacter = (char: string): string => {
  const code = char.charCodeAt(0);

  return (
    swiftEscapes[char] ??
    (code < 0x20 || code === 0x7f ? `\\u{${code.toString(16).toUpperCase()}}` : char)
  );
};

const quote = (value: string): string => `"${Array.from(value, escapeSwiftCharacter).join('')}"`;

const swiftList = (items: readonly string[], indent: number): string => {
  if (items.length === 0) {
    return '[]';
  }

  const itemIndent = ' '.repeat(indent + 4);
  return `[\n${items.map((item) => `${itemIndent}${item},\n`).join('')}${' '.repeat(indent)}]`;
};

const swiftTarget = (targetArguments: readonly string[]): string =>
  `.target(\n${targetArguments.map((argument) => `            ${argument}`).join(',\n')}\n        )`;

const hasCodegenProducts = (react: ReactDescriptor | null): boolean =>
  react?.products.some((product) => product.package === CODEGEN_PACKAGE_NAME) ?? false;

const reactDependencies = (
  react: ReactDescriptor | null,
  codegenPackagePath: string,
): {packages: string[]; products: string[]} => {
  if (react == null) {
    return {packages: [], products: []};
  }

  const {packageRef, products} = react;

  const packages = [
    'url' in packageRef
      ? `.package(url: ${quote(packageRef.url)}, exact: ${quote(packageRef.version)})`
      : `.package(name: ${quote(packageRef.name)}, path: ${quote(packageRef.path)})`,
  ];

  // React Native lists codegen products only when their package exists
  if (hasCodegenProducts(react)) {
    packages.push(
      `.package(name: ${quote(CODEGEN_PACKAGE_NAME)}, path: ${quote(codegenPackagePath)})`,
    );
  }

  return {
    packages,
    products: products.map(
      (product) => `.product(name: ${quote(product.name)}, package: ${quote(product.package)})`,
    ),
  };
};

// Renders a Package.swift with only the chosen handlers. It expects a `root`
// symlink to the library's `ios` folder and an `include` folder next to it.
export const renderPackageManifest = ({
  permissions,
  react,
  codegenPackagePath,
}: {
  permissions: readonly IosPermission[];
  react: ReactDescriptor | null;
  codegenPackagePath: string;
}): string => {
  const folders = unique(permissions).sort();
  const dependencies = reactDependencies(react, codegenPackagePath);

  const swiftFiles = folders.reduce<string[]>(
    (files, folder) =>
      files.concat((swiftSources[folder] ?? []).map((file) => `${folder}/${file}`)),
    [],
  );

  const frameworks = unique(
    folders.reduce<string[]>((all, folder) => all.concat(iosPermissionFrameworks[folder]), []),
  ).sort();

  const headerSearchPaths = ['root', ...folders.map((folder) => `root/${folder}`)].map(
    (headerPath) => `.headerSearchPath(${quote(headerPath)})`,
  );

  const sharedSettings = [...headerSearchPaths, '.define("RCT_NEW_ARCH_ENABLED")'];

  const targets = [
    swiftTarget([
      `name: ${quote(PACKAGE_NAME)}`,
      `dependencies: ${swiftList(
        [...dependencies.products, ...(swiftFiles.length > 0 ? [quote(SWIFT_TARGET_NAME)] : [])],
        12,
      )}`,
      'path: "."',
      `exclude: ${swiftList(
        swiftFiles.map((file) => quote(`root/${file}`)),
        12,
      )}`,
      `sources: ${swiftList(
        ['root/RNPermissions.mm', ...folders.map((folder) => `root/${folder}`)].map(quote),
        12,
      )}`,
      'resources: [.copy("root/PrivacyInfo.xcprivacy")]',
      // Can't be `root`: SwiftPM rejects RNPermissions.h as an umbrella header
      // when folders sit next to it
      'publicHeadersPath: "include"',
      `cSettings: ${swiftList(sharedSettings, 12)}`,
      `cxxSettings: ${swiftList(
        [
          ...sharedSettings,
          '.define("DEBUG", .when(configuration: .debug))',
          '.define("NDEBUG", .when(configuration: .release))',
        ],
        12,
      )}`,
      `linkerSettings: ${swiftList(
        frameworks.map((framework) => `.linkedFramework(${quote(framework)})`),
        12,
      )}`,
    ]),
    ...(swiftFiles.length > 0
      ? [
          swiftTarget([
            `name: ${quote(SWIFT_TARGET_NAME)}`,
            'path: "root"',
            // The main target already ships it, SwiftPM would bundle it again
            'exclude: ["PrivacyInfo.xcprivacy"]',
            `sources: ${swiftList(swiftFiles.map(quote), 12)}`,
            // Matches the podspec's swift_version (5.9)
            'swiftSettings: [.swiftLanguageMode(.v5)]',
          ]),
        ]
      : []),
  ];

  return `// swift-tools-version: 6.0
// Generated by react-native-permissions on every SwiftPM sync. Do not edit.

import PackageDescription

let package = Package(
    name: ${quote(PACKAGE_NAME)},
    platforms: [.iOS("15.1")],
    products: [
        .library(name: ${quote(PACKAGE_NAME)}, targets: [${quote(PACKAGE_NAME)}]),
    ],
    dependencies: ${swiftList(dependencies.packages, 4)},
    targets: [
${targets.map((target) => `        ${target},\n`).join('')}    ],
    cxxLanguageStandard: .cxx20
)
`;
};

const writeFileIfChanged = (filePath: string, contents: string): void => {
  if (!fs.existsSync(filePath) || fs.readFileSync(filePath, 'utf8') !== contents) {
    fs.writeFileSync(filePath, contents);
  }
};

const ensureSymlink = (linkPath: string, target: string): void => {
  const stat = fs.lstatSync(linkPath, {throwIfNoEntry: false});

  if (stat?.isSymbolicLink() && fs.readlinkSync(linkPath) === target) {
    return;
  }

  fs.rmSync(linkPath, {recursive: true, force: true});
  fs.symlinkSync(target, linkPath);
};

// Runs the SwiftPM autolinking plugin, which writes an RNPermissions package
// with the chosen handlers and links it into the app.
export const runSwiftPMPlugin = (
  libraryRoot: string,
  {appRoot, outputDir, react}: SwiftPMPluginContext,
): SwiftPMPluginResult => {
  const configFilePath = path.join(appRoot, CONFIG_FILE_NAME);
  const permissions = readIosPermissions(configFilePath);

  // React Native's per-app codegen package
  const codegenPackagePath = path.resolve(outputDir, '..', 'ios');
  const packageDir = path.join(outputDir, NPM_PACKAGE_NAME, PACKAGE_NAME);

  if (react == null) {
    console.warn(
      `[Permissions] React Native gave no React package, so ${PACKAGE_NAME} will not compile.`,
    );
  } else if (!hasCodegenProducts(react)) {
    console.warn(
      `[Permissions] No codegen output in ${codegenPackagePath}, so ${PACKAGE_NAME} will not compile until codegen runs.`,
    );
  }

  fs.mkdirSync(path.join(packageDir, 'include'), {recursive: true});

  // Xcode re-resolves the package when its manifest or root changes, so only
  // write them when needed
  writeFileIfChanged(
    path.join(packageDir, 'Package.swift'),
    renderPackageManifest({permissions, react, codegenPackagePath}),
  );

  // Link ios/ only: SwiftPM scans the whole package folder, so linking the
  // library root would pull in node_modules
  ensureSymlink(path.join(packageDir, 'root'), path.join(libraryRoot, 'ios'));

  return {
    packageDependencies: [{name: PACKAGE_NAME, path: packageDir}],
    productDependencies: [{name: PACKAGE_NAME, package: PACKAGE_NAME}],
    watchPaths: [configFilePath],
  };
};
