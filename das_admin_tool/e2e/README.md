# E2E testing with Playwright

The blueprint has end-to-end testing prepared using [Playwright](https://playwright.dev/).

Run the tests with `npm run e2e` from the project root directory.

## Config profiles

The following config files are prepared:

- `playwright.config.ts` holds the basic config and is used for CI testing
- `playwright.local.config.ts` extends the base config with additional browser profiles for local (
  Desktop) testing

## Automatic start of Angular dev server

Using
the [webServer](https://playwright.dev/docs/test-advanced#launching-a-development-web-server-during-the-tests)
config option, Playwright starts the Angular development server before running the tests and shuts
it down afterwards.

### User login for development

For development, personal user accounts may be used to authenticate. Because most accounts are
protected by a 2nd factor,
you should run the Playwright tests with the `--headed` flag and follow the login procedure on the
screen.

Once the login was successful, the authenticated browser state is stored in a local
file `e2e/auth-state.json` and
subsequent test runs do not require the login procedure again.

## API requests mocking

Although not shown in the blueprint, Playwright has a nice feature to mock API requests with static
or dynamic responses
produced by functions within your tests. You may use the simple
wrapper `BrowserWindow.mockJsonResponse()`
or [see the documentation](https://playwright.dev/docs/api/class-page/#page-route) for reference.

## Proxy configuration

For development or security testing with OWASP ZAP
add [proxy settings](https://playwright.dev/docs/network#http-proxy)
to your Playwright configuration like this:

```ts
const proxyHost = process.env.LOCAL_PROXY_HOST || 'localhost';
const proxyPort = process.env.LOCAL_PROXY_PORT || '8080';
const config: PlaywrightTestConfig = {
  use: {
    proxy: {
      server: `http://${proxyHost}:${proxyPort}`,
    },
  },
  projects: [
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },
  ],
};
```

> Please note that Chromium browsers do not send requests to `localhost` through the configured
> proxy.
> Therefore we recommend to use Firefox for tests running with a proxy configuration.
> Chromium might work when adding the proxy option `bypass: '<-loopback>'`.

## Test debugging and recording

Playwright can start an interactive [Inspector](https://playwright.dev/docs/inspector/) to help
authoring and debugging Playwright scripts.
Prefix your test run script with `PWDEBUG=1` to open it or see the documentation for more options.

Another handy feature to create tests in the first place is
the [Test Generator](https://playwright.dev/docs/codegen)
which will record the user interactions and generate code for them.

Open it with `npx playwright codegen localhost:4200` after starting the Angular CLI server.
