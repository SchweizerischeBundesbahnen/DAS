import { ElementHandle, Page } from '@playwright/test';

/**
 * Utility class providing functions to navigate in a browser window
 */
export class BrowserWindow {
  constructor(private page: Page) {}

  /**
   * Factory method
   *
   * @param page
   */
  static init(page: Page): BrowserWindow {
    return new BrowserWindow(page);
  }

  /**
   * Wrapper for page.click()
   *
   * @param selector
   * @see https://playwright.dev/docs/api/class-page#page-click
   */
  async click(selector: string): Promise<void> {
    //console.debug('Clicking element: ', selector);
    await this.page.locator(selector).click();
    //console.debug('Clicked element: ', selector);
  }

  /**
   * Wait for an element to become visible
   *
   * @param selector
   * @param timeout
   * @see https://playwright.dev/docs/api/class-page#page-wait-for-selector
   */
  async waitUntilVisible(selector: string, timeout = 10000): Promise<void> {
    //console.debug('Waiting for element to be visible ' + selector);
    const elem = await this.page.waitForSelector(selector, {
      state: 'visible',
      timeout: timeout,
    });
    console.debug("Element: '%s' is visible", (await elem.innerText()).trim());
  }

  /**
   * Getter for the Playwright Page instance
   *
   * @return Page
   */
  getPage(): Page {
    return this.page;
  }

  /**
   * Finds an element matching the specified selector within the page
   *
   * If no elements match the selector, the return value resolves to `null`.
   *
   * @param selector
   * @see https://playwright.dev/docs/api/class-page#page-query-selector
   */
  async getElement(selector: string): Promise<ElementHandle<SVGElement | HTMLElement> | null> {
    return this.page.$(selector);
  }

  /**
   * Fill a given value into a (visible) input element
   *
   * @param selector
   * @param value
   */
  async fillInput(selector: string, value: string): Promise<void> {
    //console.debug('Sending input %s to the element: %s', value, selector);
    return await this.page.locator(selector).fill(value);
  }

  /**
   * Mock the response of a network request expecting a JSON response
   *
   * @param routePath Pattern of the route/url to mock
   * @param jsonData JSON payload
   * @param statusCode The status code to return
   * @see https://playwright.dev/docs/api/class-page#page-route
   */
  mockJsonResponse(routePath: string, jsonData: string, statusCode = 200): Promise<void> {
    return this.page.route(routePath, (route) =>
      route.fulfill({
        status: statusCode,
        contentType: 'application/json',
        headers: { 'access-control-allow-origin': '*' },
        body: jsonData,
      }),
    );
  }
}
