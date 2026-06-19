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
    extends: [
      ...angular.configs.templateRecommended,
      ...angular.configs.templateAccessibility,
      prettierRecommended,
    ],
    rules: {
      // sbb-form-field handles label association internally
      '@angular-eslint/template/label-has-associated-control': 'off',
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
