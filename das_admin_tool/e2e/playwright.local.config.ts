import { devices } from '@playwright/test';
import config from './playwright.config';

config.retries = 0;
config.use!.screenshot = 'only-on-failure';
config.projects = [{ name: 'chromium', use: { ...devices['Desktop Chrome'] } }];
export default config;
