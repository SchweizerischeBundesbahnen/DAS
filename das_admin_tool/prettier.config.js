// @ts-check

/** @import { Config } from "prettier"; */

/** @type {Config} */
export default {
  singleQuote: true,
  printWidth: 100,
  endOfLine: 'auto',
  objectWrap: 'collapse',
  htmlWhitespaceSensitivity: 'strict',
  experimentalOperatorPosition: 'start',
  overrides: [{ files: '*.html', options: { parser: 'angular' } }],
};
