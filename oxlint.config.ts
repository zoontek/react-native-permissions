import {defineConfig} from 'oxlint';

export default defineConfig({
  ignorePatterns: ['fetchWindowsCapabilites.js'],
  plugins: ['react', 'typescript'],
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
    'no-param-reassign': 'error',
    'no-unused-vars': ['error', {argsIgnorePattern: '^_', ignoreRestSiblings: true}],
    'no-use-before-define': 'error',
    'no-var': 'error',

    'react/react-in-jsx-scope': 'off',
    'react/button-has-type': 'error',
    'react/prefer-function-component': 'error',

    'typescript/no-wrapper-object-types': 'off',
    'typescript/explicit-function-return-type': 'error',
    'typescript/explicit-member-accessibility	': 'error',
    'typescript/explicit-module-boundary-types': 'error',
    'typescript/no-dynamic-delete': 'error',
    'typescript/no-empty-object-type': 'error',
    'typescript/no-explicit-any': 'error',
    'typescript/no-import-type-side-effects': 'error',
    'typescript/no-invalid-void-type': 'error',
    'typescript/no-namespace': 'error',
    'typescript/no-non-null-assertion': 'error',
    'typescript/no-require-imports': 'error',
    'typescript/prefer-literal-enum-member': 'off',
  },
});
