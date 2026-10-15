import { randomInt } from 'node:crypto';
import test, { expect } from '@playwright/test';
import {
  clickAddButton,
  deleteEntryViaDialog,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
  selectAnyOption,
  uniqueSuffix,
} from '../utils/admin-test-helpers';

/**
 * Codes 0001-0099 are reserved for this test. Each run picks a random one so parallel CI runs
 * against the shared dev backend don't collide.
 */
function randomTestCode(): string {
  return `00${String(randomInt(1, 100)).padStart(2, '0')}`;
}

test.describe('companies test', () => {
  const TEST_TENANT_ID = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a';

  let testCode: string;
  let testShortName: string;
  let testShortNameUpdated: string;

  test.beforeEach(() => {
    testCode = randomTestCode();
    testShortName = `TEST_${uniqueSuffix()}`;
    testShortNameUpdated = `${testShortName}_UPDATED`;
  });

  test('company_whenCreatedEditedAndDeleted_thenSucceeds|X3AAEqNVkEJsfnioDCRd|tests:1878', async ({
    page,
  }) => {
    const companiesLoaded = page.waitForResponse(
      (resp) =>
        resp.request().method() === 'GET'
        && ['xhr', 'fetch'].includes(resp.request().resourceType())
        && new URL(resp.url()).pathname.endsWith('/companies'),
    );
    await page.goto('das-admin/companies');
    await companiesLoaded;
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('EVUs');
    // the title renders before the data arrives, wait for rows before using the table
    await expect(page.locator('tr[sbb-row]').first()).toBeVisible();

    const row = findRow(page, testShortName);
    const updatedRow = findRow(page, testShortNameUpdated);

    // create
    await clickAddButton(page);

    const dialog = await getEntryDialog(page);

    await dialog.getByRole('textbox', { name: 'Code' }).fill(testCode);
    await dialog.getByRole('textbox', { name: 'Kurzname (NeTS)' }).fill(testShortName);
    const select = dialog.locator('sbb-select');
    await selectAnyOption(dialog, select, null);

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Die EVU wurde erfolgreich erstellt.',
      dialogTitle: 'EVU erfassen',
    });

    await expect(row.getByRole('cell', { name: testCode, exact: true })).toBeVisible();
    await expect(row.getByRole('cell', { name: testShortName, exact: true })).toBeVisible();
    await expect(
      row.getByRole('cell', { name: `${TEST_TENANT_ID} - sbb`, exact: true }),
    ).toBeVisible();

    // edit
    const editDialog = await openEditEntryDialog(page, row);
    const shortNameInput = editDialog.getByRole('textbox', { name: 'Kurzname (NeTS)' });
    await expect(shortNameInput).toHaveValue(testShortName);
    await shortNameInput.fill(testShortNameUpdated);
    await expect(shortNameInput).toHaveValue(testShortNameUpdated);

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Die EVU wurde erfolgreich gespeichert.',
      dialogTitle: 'EVU bearbeiten',
    });

    await expect(
      updatedRow.getByRole('cell', { name: testShortNameUpdated, exact: true }),
    ).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, updatedRow);
  });
});
