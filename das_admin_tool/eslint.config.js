// @ts-check

import { defineConfig } from 'eslint/config';
import css from '@eslint/css';
import js from '@eslint/js';
import json from '@eslint/json';
import * as ts from 'typescript-eslint';
import * as angular from 'angular-eslint';
import prettierRecommended from 'eslint-plugin-prettier/recommended';

export default defineConfig(
  {
    files: ['**/*.ts'],
    extends: [
      js.configs.recommended,
      ...ts.configs.recommended,
      ...ts.configs.stylistic,
      ...angular.configs.tsRecommended,
      prettierRecommended,
    ],
    processor: angular.processInlineTemplates,
    languageOptions: { parserOptions: { projectService: true } },
    rules: {
      '@angular-eslint/component-selector': [
        'error',
        { type: 'element', prefix: 'app', style: 'kebab-case' },
      ],
      '@angular-eslint/directive-selector': [
        'error',
        { type: 'attribute', prefix: 'app', style: 'camelCase' },
      ],
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
