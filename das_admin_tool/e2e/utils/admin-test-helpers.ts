import { expect, Locator, Page } from '@playwright/test';

/**
 * Generic helpers for ru admin feature tests
 */
export function findRow(page: Page, ...cellTexts: string[]): Locator {
  let loc: Locator = page.locator('tr[sbb-row]');
  for (const txt of cellTexts) {
    loc = loc.filter({ has: page.getByRole('cell', { name: txt, exact: true }) });
  }
  return loc.first();
}

/**
 * Navigate through paginator pages until the row is visible or no more pages.
 * Returns true if the row was found visible.
 */
async function navigateToRow(page: Page, row: Locator): Promise<boolean> {
  if (await row.isVisible()) {
    return true;
  }

  const paginator = page.locator('sbb-compact-paginator');
  if (!(await paginator.isVisible())) {
    return false;
  }

  const buttons = paginator.locator('sbb-mini-button');
  const maxPages = 20;
  const previousButton = buttons.first();
  const nextButton = buttons.last();

  const canClick = async (button: Locator) => {
    if (!(await button.isVisible())) {
      return false;
    }
    return !(await button.evaluate(
      (el) => el.hasAttribute('disabled') || (el as HTMLButtonElement).disabled,
    ));
  };

  const walkPages = async (button: Locator, stopOnRowFound: boolean): Promise<boolean> => {
    for (let i = 0; i < maxPages; i++) {
      if (!(await canClick(button))) {
        break;
      }
      await button.click();
      await page.waitForTimeout(200);
      if (stopOnRowFound && (await row.isVisible())) {
        return true;
      }
    }
    return false;
  };

  // Rewind to first page so searches are deterministic regardless current paginator state.
  await walkPages(previousButton, false);

  if (await row.isVisible()) {
    return true;
  }

  // Scan forward page-by-page.
  return await walkPages(nextButton, true);
}

async function expectRowPresent(page: Page, row: Locator, timeout = 10000) {
  await expect
    .poll(async () => await navigateToRow(page, row), {
      timeout,
      message: 'Expected row to be found while navigating paginator pages',
    })
    .toBeTruthy();
  await expect(row).toBeVisible();
}

async function expectRowAbsent(page: Page, row: Locator, timeout = 10000) {
  await expect
    .poll(async () => await navigateToRow(page, row), {
      timeout,
      message: 'Expected row to be absent while navigating paginator pages',
    })
    .toBeFalsy();
}

export async function clickAddButton(page: Page) {
  const addButton = page.getByText('Neuen Eintrag erfassen', { exact: true });
  await expect(addButton).toBeVisible();
  await addButton.click();
}

export async function getEntryDialog(page: Page) {
  const dialog = page.locator('sbb-dialog');
  await expect(dialog).toBeVisible();
  return dialog;
}

export async function saveEntryDialog(
  page: Page,
  row: Locator,
  options: { method: 'POST' | 'PUT'; successToast: string; dialogTitle: string },
) {
  const saveResponse = waitForResponse(page, options.method);
  const reloadResponse = waitForResponse(page, 'GET');
  if (options.method === 'PUT') {
    await page.getByText('Weiter', { exact: true }).click();
  }
  await page.getByText('Speichern', { exact: true }).click();
  await saveResponse;
  await reloadResponse;
  await expect(page.getByText(options.successToast, { exact: true })).toBeVisible();
  await expect(page.getByText(options.dialogTitle, { exact: true })).not.toBeVisible();

  await expectRowPresent(page, row);
}

export async function openEditEntryDialog(page: Page, row: Locator) {
  await expectRowPresent(page, row);
  await row.locator('sbb-mini-button').click();

  return await getEntryDialog(page);
}

export async function deleteEntryViaDialog(page: Page, row: Locator) {
  const dialog = await openEditEntryDialog(page, row);

  const deleteResponse = waitForResponse(page, 'DELETE');
  const reloadResponse = waitForResponse(page, 'GET');
  const deleteBtn = dialog.getByText('Eintrag löschen', { exact: true });
  await expect(deleteBtn).toBeVisible();
  await deleteBtn.click();
  await deleteResponse;
  await reloadResponse;
  await expectRowAbsent(page, row);
}

export async function deleteEntryIfExists(page: Page, row: Locator): Promise<boolean> {
  const found = await navigateToRow(page, row);
  if (!found) {
    return false;
  }

  await deleteEntryViaDialog(page, row);
  return true;
}

export async function deleteEntryViaSelection(page: Page, ...rows: Locator[]) {
  if (rows.length === 0) {
    return;
  }
  for (const row of rows) {
    if ((await row.isVisible()) || (await navigateToRow(page, row))) {
      await row.locator('sbb-checkbox').click();
    }
  }
  const deleteResponse = waitForResponse(page, 'DELETE');
  const reloadResponse = waitForResponse(page, 'GET');
  await page.getByText('löschen').click();
  await deleteResponse;
  await reloadResponse;
  for (const row of rows) {
    await expectRowAbsent(page, row);
  }
}

export async function selectAnyOption(
  dialog: Locator,
  inputLocator: Locator,
  query: string | null = '',
) {
  await inputLocator.click();

  if (query) {
    await inputLocator.fill(query);
  }

  const firstVisibleOption = dialog.locator('sbb-option:visible').first();
  await expect(firstVisibleOption).toBeVisible();
  await firstVisibleOption.click();
}

async function waitForResponse(page: Page, method: 'POST' | 'PUT' | 'DELETE' | 'GET') {
  return page.waitForResponse((resp) => {
    const req = resp.request();
    return req.method() === method && ['xhr', 'fetch'].includes(req.resourceType()) && resp.ok();
  });
}
