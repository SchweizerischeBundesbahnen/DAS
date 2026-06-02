import { expect, Locator, Page } from '@playwright/test';

/**
 * Generic helpers for ru admin feature tests
 */
export function findRow(page: Page, ...cellTexts: string[]): Locator {
  let loc: Locator = page.locator('tr[sbb-row]');
  for (const txt of cellTexts) {
    loc = loc.filter({has: page.getByRole('cell', {name: txt, exact: true})});
  }
  return loc.first();
}

export async function openEditDialog(row: Locator) {
  await row.locator('sbb-mini-button').click();
}

export async function deleteEntryDialog(page: Page, row: Locator) {
  await openEditDialog(row);
  const dialog = page.locator('sbb-dialog-actions');
  await expect(dialog).toBeVisible();

  const deleteResponse = page.waitForResponse((resp) => resp.request().method() === 'DELETE');
  const deleteBtn = dialog.getByText('löschen');
  await expect(deleteBtn).toBeVisible();
  await deleteBtn.click();
  await deleteResponse;
  await expect(row).not.toBeVisible();
}

export async function deleteBySelecting(page: Page, ...cellTexts: string[]) {
  const rows: Locator[] = [];
  for (const txt of cellTexts) {
    const row = findRow(page, txt);
    if (await row.isVisible()) {
      await row.locator('sbb-checkbox').click();
      rows.push(row);
    }
  }
  if (rows.length === 0) {
    return;
  }
  const deleteResponse = page.waitForResponse((resp) => resp.request().method() === 'DELETE');
  await page.getByText('löschen').click();
  await deleteResponse;
  for (const row of rows) {
    await expect(row).not.toBeVisible();
  }
}

export async function selectAnyOption(page: Page, inputLocator: Locator, query = '') {
  await inputLocator.click();

  await inputLocator.fill(query);

  const firstVisibleOption = page.locator('sbb-option:visible').first();
  await expect(firstVisibleOption).toBeVisible({timeout: 5000});
  await firstVisibleOption.click();
}
