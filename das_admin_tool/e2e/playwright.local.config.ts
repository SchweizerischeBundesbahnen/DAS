import config from './playwright.config';

config.retries = 0;
config.use!.screenshot = 'only-on-failure';
export default config;
