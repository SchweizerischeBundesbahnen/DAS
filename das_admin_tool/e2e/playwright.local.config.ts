import {devices} from '@playwright/test';
import config from './playwright.config';

config.retries = 0;
config.use!.screenshot = 'only-on-failure';
config.projects = [
  {
    name: 'firefox',
    use: {...devices['Desktop Firefox']},
  },
  {
    name: 'chromium',
    use: {...devices['Desktop Chrome']},
  },
  {
    name: 'webkit',
    use: {...devices['Desktop Safari']},
  },
  {
    name: 'msedge',
    use: {
      // Supported Microsoft Edge channels are: msedge, msedge-beta, msedge-dev, msedge-canary
      channel: 'msedge',
    },
  },
];
export default config;
