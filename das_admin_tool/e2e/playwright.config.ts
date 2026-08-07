import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: 'tests',
  forbidOnly: !!process.env['CI'],
  retries: process.env['CI'] ? 2 : 0,
  globalSetup: './global-setup',
  reporter: process.env['CI']
    ? [['list'], ['json', { outputFile: 'test-results.json' }]]
    : [['list']],
  use: {
    baseURL: 'http://localhost:4200',
    viewport: { width: 1280, height: 1580 },
    ignoreHTTPSErrors: true,
    trace: 'on-first-retry',
    storageState: 'e2e/auth-state.json',
  },
  webServer: {
    command: 'npx ng serve --configuration=e2e',
    url: 'http://localhost:4200',
    timeout: 120 * 1000,
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
