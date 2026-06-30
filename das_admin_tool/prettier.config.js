// @ts-check

/** @import { Config } from "prettier"; */

/** @type {Config} */
export default {
	singleQuote: true,
	printWidth: 100,
	endOfLine: 'auto',
	objectWrap: 'collapse',
	useTabs: true,
	htmlWhitespaceSensitivity: 'strict',
	experimentalOperatorPosition: 'start',
	overrides: [
		{ files: '*.html', options: { parser: 'angular' } },
		{ files: ['package.json', 'package-lock.json'], options: { useTabs: false } },
	],
};
