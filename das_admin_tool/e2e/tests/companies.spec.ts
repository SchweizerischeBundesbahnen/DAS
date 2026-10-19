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
import { CompaniesApi } from '../utils/companies-api';

/**
 * Uses random codes in the range of 0001-0099 for parallel runs without collisions.
 *
 */
function randomTestCode(): string {
  return `00${String(randomInt(1, 100)).padStart(2, '0')}`;
}

test.describe('companies test', () => {
  const TEST_TENANT_ID = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a';

  let testCode: string;
  let testShortName: string;
  let testShortNameUpdated: string;
  let companiesApi: CompaniesApi | undefined;

  test.beforeEach(async ({ page }) => {
    testCode = randomTestCode();
    testShortName = `TEST_${uniqueSuffix()}`;
    testShortNameUpdated = `${testShortName}_UPDATED`;
    companiesApi = undefined;

    const companiesLoaded = page.waitForResponse(
      (resp) =>
        resp.request().method() === 'GET'
        && ['xhr', 'fetch'].includes(resp.request().resourceType())
        && new URL(resp.url()).pathname.endsWith('/companies'),
    );
    await page.goto('das-admin/companies');
    companiesApi = await CompaniesApi.fromListResponse(page, await companiesLoaded);
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('EVUs');
    // the title renders before the data arrives, wait for rows before using the table
    await expect(page.locator('tr[sbb-row]').first()).toBeVisible();
  });

  test.afterEach(async () => {
    if (!companiesApi) {
      return;
    }
    // runs also when the test failed halfway; match the short name too, if the create failed with
    // 409 the company with this code belongs to a parallel run that picked the same code
    const own = (await companiesApi.list()).find(
      (company) => company.code === testCode && company.shortName.startsWith(testShortName),
    );
    if (own) {
      await companiesApi.delete(own.id);
    }
  });

  test('company_whenCreatedEditedAndDeleted_thenSucceeds|X3AAEqNVkEJsfnioDCRd|tests:1878', async ({
    page,
  }) => {
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
