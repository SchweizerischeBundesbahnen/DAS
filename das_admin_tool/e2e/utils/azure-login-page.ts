import {BrowserWindow} from './browser-window';

const INPUT_MAIL = '[type=email]';
const INPUT_PASSWORD = '[type=password]';
const BUTTON_SIGN_IN = 'input:has-text("Sign in")';
const BUTTON_NEXT = 'text=Next';
const MAX_LOGIN_TIME = 120000;
const LOGIN_USERNAME = process.env['E2E_LOGIN_USERNAME'] || '';
const LOGIN_PASSWORD = process.env['E2E_LOGIN_PASSWORD'] || '';

/**
 * Page Object Model for an Azure AD login page
 * @see https://playwright.dev/docs/test-pom
 */
export class AzureLoginPage {
  constructor(
    private browser: BrowserWindow,
    private baseURL: string,
  ) {
  }

  async login(interactive = false): Promise<void> {
    console.debug('Trying to login with:', LOGIN_USERNAME);
    await this.browser.fillInput(INPUT_MAIL, LOGIN_USERNAME);
    await this.browser.click(BUTTON_NEXT);
    await this.browser.fillInput(INPUT_PASSWORD, LOGIN_PASSWORD);
    await this.browser.click(BUTTON_SIGN_IN);
    try {
      // Check if automatically redirected
      await this.browser.getPage().waitForURL(this.baseURL, {timeout: 2000});
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (err: unknown) {
      await this.checkPasswordError(interactive);
      await this.check2ndFactorAuth();
      await this.browser.getPage().waitForURL(this.baseURL);
    }
    console.debug('Successfully logged in to Azure');
  }

  async checkPasswordError(interactive: boolean): Promise<void> {
    if (
      (await this.browser.getElement('#passwordError')) ||
      (await this.browser.getElement('#userNameError'))
    ) {
      if (interactive) {
        this.browser.getPage().setDefaultTimeout(MAX_LOGIN_TIME);
      } else {
        throw new Error(
          '*** Login failed with the given credentials. Run playwright with --headed for an interactive login process ***',
        );
      }
    }
  }

  async check2ndFactorAuth(): Promise<void> {
    if (await this.browser.getElement('text=Approve sign-in request')) {
      console.info('*** Approve sign-in request with your 2nd factor ***');
      console.info('*** Run playwright with --headed for an interactive login process ***');
      this.browser.getPage().setDefaultTimeout(MAX_LOGIN_TIME);
    }
  }
}
