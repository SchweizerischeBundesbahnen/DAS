import fs from 'fs';
import path from 'path';
import { chromium, firefox, FullConfig } from '@playwright/test';
import { AzureLoginPage } from './utils/azure-login-page';
import { BrowserWindow } from './utils/browser-window';

export default async function globalSetup(config: FullConfig) {
  const { baseURL, storageState, defaultBrowserType } = config.projects[0].use;
  const storageStatePath = path.resolve(storageState as string);

  if (!fs.existsSync(storageStatePath)) {
    const engine = defaultBrowserType === 'firefox' ? firefox : chromium;
    const headless = !process.argv.includes('--headed');
    const browser = await engine.launch({ headless });
    const page = await browser.newPage();
    await page.goto(baseURL!, { waitUntil: 'domcontentloaded' });
    await page.waitForURL('https://login.microsoftonline.com/**');
    await new AzureLoginPage(BrowserWindow.init(page), baseURL!).login(!headless);
    await page.context().storageState({ path: storageState as string });
    await browser.close();
  } else {
    console.log(
      `Use existing state from ${storageStatePath}. If you get authentication errors delete this file.`,
    );
  }
}
