// @ts-check

import css from '@eslint/css';
import js from '@eslint/js';
import json from '@eslint/json';
import * as angular from 'angular-eslint';
import { defineConfig } from 'eslint/config';
import * as importX from 'eslint-plugin-import-x';
import * as sonarjs from 'eslint-plugin-sonarjs';
import unicorn from 'eslint-plugin-unicorn';
import prettierRecommended from 'eslint-plugin-prettier/recommended';
import * as ts from 'typescript-eslint';

export default defineConfig(
  {
    files: ['**/*.ts'],
    extends: [
      js.configs.recommended,
      ...ts.configs.recommendedTypeChecked,
      ...ts.configs.stylisticTypeChecked,
      ...angular.configs.tsAll,
      importX.flatConfigs.recommended,
      importX.flatConfigs.typescript,
      sonarjs.configs.recommended,
      unicorn.configs.recommended,
      prettierRecommended,
    ],
    processor: angular.processInlineTemplates,
    languageOptions: { parserOptions: { projectService: true } },
    rules: {
      // eslint
      eqeqeq: 'error',
      'max-depth': 'error',
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['~src/app/ru-admin/*', '~app/ru-admin/*', '../ru-admin/*', './ru-admin/*'],
              message: "Please use '~ru-admin/*'",
            },
            {
              group: ['~src/app/shared/*', '~app/shared/*', '../shared/*', './shared/*'],
              message: "Please use '~shared/*'",
            },
            { group: ['~src/app/*', '../app/*', './app/*'], message: "Please use '~app/*'" },
            { group: ['../../*'], message: 'Please use an absolute path' },
            {
              group: ['@angular/common'],
              importNames: ['CommonModule'],
              message: 'Please use more granular imports!',
            },
          ],
        },
      ],
      'prefer-template': 'error',
      // @typescript-eslint
      '@typescript-eslint/dot-notation': [
        'error',
        // Allowed for tests and environment variables
        {
          allowPrivateClassPropertyAccess: true,
          allowProtectedClassPropertyAccess: true,
          allowIndexSignaturePropertyAccess: true,
        },
      ],
      '@typescript-eslint/no-unused-vars': [
        'error',
        // Allowed for underline variables
        {
          vars: 'all',
          varsIgnorePattern: '^_',
          args: 'all',
          argsIgnorePattern: '^_',
          caughtErrors: 'all',
          caughtErrorsIgnorePattern: '^_',
        },
      ],
      '@typescript-eslint/unbound-method': [
        'error',
        {
          // Ignored because form validators get reported
          ignoreStatic: true,
        },
      ],
      // @angular-eslint
      // Disabled because of new style guide
      '@angular-eslint/component-class-suffix': 'off',
      '@angular-eslint/component-selector': [
        'error',
        { type: 'element', prefix: 'app', style: 'kebab-case' },
      ],
      '@angular-eslint/directive-selector': [
        'error',
        { type: 'attribute', prefix: 'app', style: 'camelCase' },
      ],
      'import-x/order': [
        'error',
        {
          groups: [
            'builtin',
            'external',
            'internal',
            'parent',
            'sibling',
            'index',
            'object',
            'type',
          ],
          'newlines-between': 'never',
          alphabetize: { order: 'asc', caseInsensitive: true },
          named: true,
        },
      ],
      // sonarjs
      // Disabled because this is opinionated
      'sonarjs/function-return-type': 'off',
      // Disabled because handled by sonarjs/cognitive-complexity
      'sonarjs/no-nested-conditional': 'off',
      // unicorn
      // Disabled because these rules are opinionated
      'unicorn/catch-error-name': 'off',
      'unicorn/consistent-boolean-name': 'off',
      'unicorn/consistent-class-member-order': 'off',
      'unicorn/import-style': 'off',
      'unicorn/name-replacements': 'off',
      'unicorn/no-array-callback-reference': 'off',
      'unicorn/no-array-sort': 'off',
      'unicorn/no-await-expression-member': 'off',
      'unicorn/no-for-each': 'off',
      'unicorn/no-negated-condition': 'off',
      'unicorn/no-non-function-verb-prefix': 'off',
      'unicorn/no-null': 'off',
      'unicorn/no-useless-else': 'off',
      'unicorn/prefer-early-return': 'off',
      'unicorn/prefer-export-from': 'off',
      'unicorn/prefer-node-protocol': 'off',
      'unicorn/prefer-set-has': 'off',
      // Disabled because used in angular
      'unicorn/prefer-top-level-await': 'off',
      'unicorn/prefer-await': 'off',
      // Disabled because handled by sonarjs/cognitive-complexity
      'unicorn/max-nested-calls': 'off',
    },
  },
  {
    files: ['**/*.html'],
    extends: [...angular.configs.templateAll, prettierRecommended],
    rules: {
      // Disabled because sbb-component attributes get reported
      '@angular-eslint/template/i18n': 'off',
      // Disabled because signals get reported
      '@angular-eslint/template/no-call-expression': 'off',
    },
  },
  { files: ['**/*.css'], language: 'css/css', plugins: { css }, extends: [prettierRecommended] },
  {
    files: ['**/*.json'],
    language: 'json/jsonc',
    plugins: { json },
    extends: [prettierRecommended],
  },
);
