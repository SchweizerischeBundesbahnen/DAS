import config from './playwright.config';
import { devices } from '@playwright/test';

config.retries = 0;
config.use!.screenshot = 'only-on-failure';
config.projects = [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }];
export default config;
