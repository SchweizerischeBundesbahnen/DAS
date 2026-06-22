import { existsSync } from 'fs';
import { resolve } from 'path';
import { chromium, firefox, FullConfig } from '@playwright/test';
import { BrowserWindow } from './utils/browser-window';
import { MsEntraIdLoginPage } from './utils/ms-entra-id-login-page';

export default async function globalSetup(config: FullConfig) {
	const { baseURL, storageState, defaultBrowserType } = config.projects[0].use;
	const storageStatePath = resolve(storageState as string);

	if (existsSync(storageStatePath)) {
		console.log(
			`Use existing state from ${storageStatePath}. If you get authentication errors delete this file.`,
		);
	} else {
		const engine = defaultBrowserType === 'firefox' ? firefox : chromium;
		const headless = !process.argv.includes('--headed');
		const browser = await engine.launch({ headless });
		const page = await browser.newPage();
		await page.goto(baseURL!, { waitUntil: 'domcontentloaded' });
		await page.waitForURL('https://login.microsoftonline.com/**');
		await new MsEntraIdLoginPage(BrowserWindow.init(page), baseURL!).login(!headless);
		await page.context().storageState({ path: storageState as string });
		await browser.close();
	}
}
