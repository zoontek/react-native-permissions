import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '..');
const file = fs.readFileSync(path.join(root, 'RNPermissions.podspec'), 'utf-8');
const lines = new Set(file.split('\n').map((line) => line.trim()));

if (!lines.has('s.source_files = "ios/*.{h,mm}"') || !lines.has('# s.frameworks = <frameworks>')) {
  console.error('Invalid podspec file');
  process.exit(1);
}
