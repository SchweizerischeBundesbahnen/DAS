---
name: angular-testing
description: 'Write and run tests for the DAS Admin Tool. Use when implementing features, adding components, creating services, fixing bugs, writing unit tests, or adding Playwright e2e tests. Tests are mandatory for every implementation task — not optional.'
---

# Angular Admin Tool Testing

## When to Use This Skill

**This skill applies to every implementation task** — not just when explicitly asked to write tests.

- Implementing a new feature → write unit tests for business logic + e2e test for the user flow
- Fixing a bug → add a regression test
- Adding/changing a service → write a service unit test
- Adding a new admin page or dialog → add a Playwright e2e test

## Testing Strategy

**Always write:**
- **Unit tests** for services and classes with business logic (`.spec.ts` co-located with the source)
- **Playwright e2e tests** for user-facing flows (CRUD operations, navigation, dialogs)

**Additionally write:**
- Unit tests for components only when they contain non-trivial logic (complex computed state, conditional rendering logic)
- Unit tests for utilities, validators, and mappers

In short: business logic gets unit tests, user flows get e2e tests.

## Running Tests

```sh
# Unit tests (Vitest, CI mode)
npm run test

# E2E tests (Playwright, starts Angular dev server automatically)
npm run e2e

# E2E local (no retries, screenshot on failure)
npm run e2e:local

# E2E local headed (see the browser)
npm run e2e:local:headed
```

## Unit Tests (Vitest)

Framework: **Vitest** with Angular TestBed. Files are co-located as `*.spec.ts` next to the source.

### Service Test Pattern

```typescript
import { TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { MyService } from './my.service';
import { MyApi } from '../my-api';
import { ToastService } from '../../shared/toast-service';

const mockApi: Partial<MyApi> = {
  getData: () => of({ data: [] }),
  postData: () => of({}),
};

const mockToastService: Partial<ToastService> = { success: vi.fn(), error: vi.fn() };

describe('MyService', () => {
  let service: MyService;

  beforeEach(() => {
    vi.clearAllMocks();

    TestBed.configureTestingModule({
      providers: [
        MyService,
        { provide: MyApi, useValue: mockApi },
        { provide: ToastService, useValue: mockToastService },
      ],
    });

    service = TestBed.inject(MyService);
  });

  it('should do something', async () => {
    const apiSpy = vi.spyOn(mockApi, 'postData');

    await service.doSomething();

    expect(apiSpy).toHaveBeenCalledWith(expectedPayload);
    expect(mockToastService.success).toHaveBeenCalled();
  });

  it('should handle API error', async () => {
    vi.spyOn(mockApi, 'postData').mockReturnValueOnce(
      throwError(() => new Error('API error')),
    );

    await service.doSomething();

    expect(mockToastService.error).toHaveBeenCalled();
  });
});
```

**Conventions:**
- Use `vi.fn()` and `vi.spyOn()` for mocking (Vitest globals)
- Use `TestBed.configureTestingModule` with provider mocks
- Use `describe` / `it` blocks with clear descriptions
- Call `vi.clearAllMocks()` in `beforeEach`
- Test success paths, error paths, and edge cases

## E2E Tests (Playwright)

Framework: **Playwright**. Tests live in `e2e/tests/`. Shared helpers in `e2e/utils/`.

### E2E Test Pattern

```typescript
import test, { expect, Locator, Page } from '@playwright/test';
import {
  clickAddButton,
  deleteEntryIfExists,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
  deleteEntryViaDialog,
} from '../utils/admin-test-helpers';

test.describe('my feature test', () => {
  const TEST_NAME = 'E2E Test Entry';
  let row: Locator;

  test.beforeEach(async ({ page }) => {
    await page.goto('my-feature-route');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('My Feature');

    row = findRow(page, TEST_NAME);
    await deleteEntryIfExists(page, row);
  });

  test('create, edit and delete entry', async ({ page }) => {
    // create
    await clickAddButton(page);
    const dialog = await getEntryDialog(page);
    await dialog.getByRole('textbox', { name: 'Name' }).fill(TEST_NAME);
    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Entry created.',
      dialogTitle: 'Create Entry',
    });
    await expect(row.getByRole('cell', { name: TEST_NAME })).toBeVisible();

    // edit
    const editDialog = await openEditEntryDialog(page, row);
    await editDialog.getByRole('textbox', { name: 'Name' }).fill('Updated');
    // ... save

    // delete
    await deleteEntryViaDialog(page, row);
  });
});
```

**Conventions:**
- One spec file per feature/page: `e2e/tests/<feature>.spec.ts`
- Use shared helpers from `e2e/utils/admin-test-helpers.ts`
- Clean up leftover test data in `beforeEach` (idempotent tests)
- Test the full CRUD cycle where applicable
- Use `findRow`, `getEntryDialog`, `saveEntryDialog` helpers for consistency
- Auth state is pre-loaded from `e2e/auth-state.json` (no login needed per test)

### E2E Authentication

- CI: Uses `global-setup.ts` to authenticate before tests
- Local: First run with `--headed` to complete 2FA login manually. The state is saved to `e2e/auth-state.json` and reused for subsequent runs.

### Shared E2E Utilities

| Helper | Purpose |
|--------|---------|
| `findRow(page, text)` | Locate a table row by cell text |
| `clickAddButton(page)` | Click the add/create button |
| `getEntryDialog(page)` | Get the currently open dialog |
| `openEditEntryDialog(page, row)` | Open edit dialog for a row |
| `saveEntryDialog(page, row, opts)` | Save dialog and assert success |
| `deleteEntryViaDialog(page, row)` | Delete entry via its edit dialog |
| `deleteEntryViaSelection(page, row)` | Delete entry via checkbox selection |
| `deleteEntryIfExists(page, row)` | Cleanup helper for idempotent tests |
| `selectAnyOption(dialog, input)` | Select first autocomplete option |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `vitest` not found | Run `npm install` first |
| E2E auth expired | Delete `e2e/auth-state.json`, run `npm run e2e:local:headed`, log in manually |
| E2E timeout on server start | Increase `webServer.timeout` in `playwright.config.ts` or start `ng serve` separately |
| Flaky e2e test | Add `await expect(...).toBeVisible()` waits before interactions |
| Tests fail on CI but pass locally | Check `retries` config; CI has 2 retries. Ensure no local state dependency. |
