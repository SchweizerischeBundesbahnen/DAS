import test, {expect} from '@playwright/test';
import {BrowserWindow} from '../utils/browser-window';

test.describe('app main test', () => {
  let browser: BrowserWindow;

  test.beforeEach(({page}) => {
    browser = BrowserWindow.init(page);
  });

  test('home view', async ({page}) => {
    await page.goto('');

    const titleBox = page.locator('sbb-title').first();
    await expect(titleBox).toHaveText('EVU Admin DAS');
  });

  test('user menu', async ({page}) => {
    await page.goto('');

    const usermenuSelector = 'sbb-menu[trigger="user-menu-trigger"]';

    await page.locator('#user-menu-trigger').click()
    await browser.waitUntilVisible(usermenuSelector);

    const userMenuPanel = page.locator(usermenuSelector);
    await expect(userMenuPanel).toContainText('Logout');
    await expect(userMenuPanel).toContainText('Account wechseln');
  });
});
