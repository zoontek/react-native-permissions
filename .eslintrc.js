const typescriptEslintRecommended = require('@typescript-eslint/eslint-plugin/dist/configs/recommended.json');
const typescriptEslintPrettier = require('eslint-config-prettier/@typescript-eslint');

module.exports = {
  extends: ['@react-native-community'],
  overrides: [
    {
      files: ['./mock.js'],
      env: {jest: true},
    },
    {
      files: ['*.ts', '*.tsx'],
      // Apply the recommended Typescript defaults and the prettier overrides to all Typescript files
      rules: Object.assign(
        typescriptEslintRecommended.rules,
        typescriptEslintPrettier.rules,
        {
          '@typescript-eslint/explicit-member-accessibility': 'off',
          '@typescript-eslint/no-empty-function': 'off',
        },
      ),
    },
    {
      files: ['example/**/*.ts', 'example/**/*.tsx'],
      rules: {
        // Turn off rules which are useless and annoying for the example files files
        '@typescript-eslint/explicit-function-return-type': 'off',
        'react-native/no-inline-styles': 'off',
      },
    },
  ],
};
