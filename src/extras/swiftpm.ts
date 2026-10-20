import fs from 'node:fs';
import path from 'node:path';
import {
  iosPermissionFrameworks,
  isIosPermission,
  type IosPermission,
} from './permissions-config.ts';

type PackageRef =
  {name: string; path: string; relPath?: string} | {name: string; url: string; version: string};

type ProductRef = {name: string; package: string};

/** How to depend on React, as passed by React Native in `context.react`. */
export type ReactDescriptor = {packageRef: PackageRef; products: ProductRef[]};

/** The subset of React Native's SwiftPM autolinking plugin context this plugin reads. */
export type SwiftPMPluginContext = {
  appRoot: string;
  projectRoot: string;
  outputDir: string;
  react: ReactDescriptor | null;
};

export type SwiftPMPluginResult = {
  packageDependencies: {name: string; path: string}[];
  productDependencies: ProductRef[];
  watchPaths: string[];
};

/** A permissions config (`{"ios": [...]}`) and the file it was read from. */
export type PermissionsSource = {path: string; config: unknown};

const PACKAGE_NAME = 'RNPermissions';
const SWIFT_TARGET_NAME = 'RNPermissionsSwift';
const CODEGEN_PACKAGE_NAME = 'React-GeneratedCode';
const NPM_PACKAGE_NAME = 'react-native-permissions';
const CONFIG_FILE_NAME = 'react-native-permissions.json';

// SwiftPM rejects targets that mix Swift and Objective-C sources, so these
// files build in their own target. The handlers find them with NSClassFromString.
const swiftSources: Partial<Record<IosPermission, readonly string[]>> = {
  Contacts: ['RNPermissionsContactPicker.swift'],
};

const unique = <T>(items: readonly T[]): T[] =>
  items.filter((item, index) => items.indexOf(item) === index);

const isRecord = (value: unknown): value is Record<string, unknown> =>
  typeof value === 'object' && value !== null && !Array.isArray(value);

const parseNames = (source: PermissionsSource): string[] => {
  const names = isRecord(source.config) ? source.config.ios : undefined;

  if (!Array.isArray(names) || !names.every((name) => typeof name === 'string')) {
    throw new Error(
      `[Permissions] Invalid iOS permissions in ${source.path}: "ios" must be an array of permission names, like ["Camera", "Notifications"].`,
    );
  }

  return unique(names);
};

const assertSameNames = (
  first: {path: string; names: string[]},
  second: {path: string; names: string[]},
): void => {
  const onlyInFirst = first.names.filter((name) => !second.names.includes(name));
  const onlyInSecond = second.names.filter((name) => !first.names.includes(name));

  if (onlyInFirst.length === 0 && onlyInSecond.length === 0) {
    return;
  }

  throw new Error(
    [
      `[Permissions] The iOS permissions in ${first.path} and ${second.path} differ.`,
      ...(onlyInFirst.length > 0 ? [`Only in ${first.path}: ${onlyInFirst.join(', ')}`] : []),
      ...(onlyInSecond.length > 0 ? [`Only in ${second.path}: ${onlyInSecond.join(', ')}`] : []),
      'Keep a single list, or make both lists the same.',
    ].join('\n'),
  );
};

/**
 * Picks the iOS permissions to compile from the app's package.json
 * (`"react-native-permissions": {"ios": [...]}`) and `ios/react-native-permissions.json`.
 */
export const resolveIosPermissions = ({
  packageJson,
  configFile,
}: {
  packageJson?: PermissionsSource;
  configFile?: PermissionsSource;
}): IosPermission[] => {
  const fromPackageJson = packageJson && {path: packageJson.path, names: parseNames(packageJson)};
  const fromConfigFile = configFile && {path: configFile.path, names: parseNames(configFile)};

  if (fromPackageJson && fromConfigFile) {
    assertSameNames(fromPackageJson, fromConfigFile);
  }

  const source = fromPackageJson ?? fromConfigFile;

  if (source == null) {
    console.warn(
      `[Permissions] No iOS permissions configured, so no permission handlers will be compiled. List them in package.json, like "${NPM_PACKAGE_NAME}": {"ios": ["Camera"]}, or with the "iosPermissions" option of the Expo config plugin.`,
    );

    return [];
  }

  const unknownNames = source.names.filter((name) => !isIosPermission(name));

  if (unknownNames.length > 0) {
    console.warn(`[Permissions] Unknown permissions: ${unknownNames.join(', ')}`);
  }

  return source.names.filter(isIosPermission);
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

const reactDependencies = (
  react: ReactDescriptor | null,
  codegenPackagePath: string | null,
): {packages: string[]; products: string[]} => {
  if (react == null) {
    return {packages: [], products: []};
  }

  const {packageRef} = react;
  const products = react.products.filter(
    (product) => product.package !== CODEGEN_PACKAGE_NAME || codegenPackagePath != null,
  );

  const packages = [
    'url' in packageRef
      ? `.package(url: ${quote(packageRef.url)}, exact: ${quote(packageRef.version)})`
      : `.package(name: ${quote(packageRef.name)}, path: ${quote(packageRef.path)})`,
  ];

  if (codegenPackagePath != null && products.some((p) => p.package === CODEGEN_PACKAGE_NAME)) {
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

/**
 * Renders a Package.swift that builds only the chosen permission handlers. It
 * expects a `root` symlink to the library's `ios` folder and an `include` folder
 * next to it.
 */
export const renderPackageManifest = ({
  permissions,
  react,
  codegenPackagePath,
}: {
  permissions: readonly IosPermission[];
  react: ReactDescriptor | null;
  codegenPackagePath: string | null;
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
      ...(swiftFiles.length > 0
        ? [
            `exclude: ${swiftList(
              swiftFiles.map((file) => quote(`root/${file}`)),
              12,
            )}`,
          ]
        : []),
      `sources: ${swiftList(
        ['root/RNPermissions.mm', ...folders.map((folder) => `root/${folder}`)].map(quote),
        12,
      )}`,
      'resources: [.copy("root/PrivacyInfo.xcprivacy")]',
      // Must exist inside the target. It cannot be `root`: SwiftPM rejects
      // RNPermissions.h as an umbrella header there because folders sit next to it.
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
      ...(frameworks.length > 0
        ? [
            `linkerSettings: ${swiftList(
              frameworks.map((framework) => `.linkedFramework(${quote(framework)})`),
              12,
            )}`,
          ]
        : []),
    ]),
    ...(swiftFiles.length > 0
      ? [
          swiftTarget([
            `name: ${quote(SWIFT_TARGET_NAME)}`,
            'path: "root"',
            `sources: ${swiftList(swiftFiles.map(quote), 12)}`,
            // Matches the podspec's swift_version (5.9)
            'swiftSettings: [.swiftLanguageMode(.v5)]',
          ]),
        ]
      : []),
  ];

  return `// swift-tools-version: 6.0
// Generated by react-native-permissions. Do not edit: it is rewritten on every SwiftPM sync.

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

const readJsonFile = (filePath: string): unknown => {
  if (!fs.existsSync(filePath)) {
    return undefined;
  }

  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch (error) {
    if (error instanceof Error) {
      error.message = `[Permissions] Could not read ${filePath}: ${error.message}`;
    }

    throw error;
  }
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

  if (stat?.isDirectory()) {
    fs.rmSync(linkPath, {recursive: true});
  } else if (stat != null) {
    fs.unlinkSync(linkPath);
  }

  fs.symlinkSync(target, linkPath);
};

/**
 * Creates the React Native SwiftPM autolinking plugin. It writes an RNPermissions
 * package with the app's chosen permission handlers, and links it into the app.
 */
export const createSwiftPMPlugin =
  (libraryRoot: string) =>
  ({appRoot, projectRoot, outputDir, react}: SwiftPMPluginContext): SwiftPMPluginResult => {
    const packageJsonPath = path.join(projectRoot, 'package.json');
    const configFilePath = path.join(appRoot, CONFIG_FILE_NAME);
    const packageJson = readJsonFile(packageJsonPath);
    const configFile = readJsonFile(configFilePath);

    const permissions = resolveIosPermissions({
      packageJson:
        isRecord(packageJson) && packageJson[NPM_PACKAGE_NAME] !== undefined
          ? {path: packageJsonPath, config: packageJson[NPM_PACKAGE_NAME]}
          : undefined,
      configFile: configFile !== undefined ? {path: configFilePath, config: configFile} : undefined,
    });

    // React Native's per-app codegen package, which is absent when codegen has not run
    const codegenPackagePath = path.resolve(outputDir, '..', 'ios');
    const packageDir = path.join(outputDir, NPM_PACKAGE_NAME, PACKAGE_NAME);

    fs.mkdirSync(path.join(packageDir, 'include'), {recursive: true});

    // Xcode re-resolves the package when its manifest or root changes, so leave
    // both untouched when they are already up to date.
    writeFileIfChanged(
      path.join(packageDir, 'Package.swift'),
      renderPackageManifest({
        permissions,
        react,
        codegenPackagePath: fs.existsSync(path.join(codegenPackagePath, 'Package.swift'))
          ? codegenPackagePath
          : null,
      }),
    );
    // Only ios/: the target path is the package folder, and SwiftPM scans all of
    // it, so linking the library root would pull in node_modules and the like.
    ensureSymlink(path.join(packageDir, 'root'), path.join(libraryRoot, 'ios'));

    return {
      packageDependencies: [{name: PACKAGE_NAME, path: packageDir}],
      productDependencies: [{name: PACKAGE_NAME, package: PACKAGE_NAME}],
      watchPaths: [packageJsonPath, configFilePath],
    };
  };
