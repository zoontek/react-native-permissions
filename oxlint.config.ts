import {defineConfig} from 'oxlint';

export default defineConfig({
  ignorePatterns: ['fetchWindowsCapabilites.js'],
  plugins: ['typescript', 'react'],
  categories: {
    correctness: 'error',
    perf: 'error',
    suspicious: 'error',
  },
  env: {
    builtin: true,
  },
  rules: {
    'no-await-in-loop': 'off',
    'no-unused-vars': ['error', {argsIgnorePattern: '^_', ignoreRestSiblings: true}],
    'react/react-in-jsx-scope': 'off',
    'typescript/no-wrapper-object-types': 'off',
  },
});
