import test, { expect } from '@playwright/test';
import {
  clickAddButton,
  deleteEntryIfExists,
  deleteEntryViaDialog,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
  selectAnyOption,
} from '../utils/admin-test-helpers';

test.describe('companies test', () => {
  const TEST_CODE = '9999';
  const TEST_SHORT_NAME = 'TEST';
  const TEST_TENANT_ID = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a';
  const TEST_SHORT_NAME_UPDATED = 'TEST_UPDATED';

  test('create, edit and delete company | tests: 1878', async ({ page }) => {
    await page.goto('das-admin/companies');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('EVUs');

    const row = findRow(page, TEST_SHORT_NAME);
    const updatedRow = findRow(page, TEST_SHORT_NAME_UPDATED);

    // clean up leftover from previous run if present
    await deleteEntryIfExists(page, row);
    await deleteEntryIfExists(page, updatedRow);

    // create
    await clickAddButton(page);

    const dialog = await getEntryDialog(page);

    await dialog.getByRole('textbox', { name: 'Code' }).fill(TEST_CODE);
    await dialog.getByRole('textbox', { name: 'Kurzname (NeTS)' }).fill(TEST_SHORT_NAME);
    const select = dialog.locator('sbb-select');
    await selectAnyOption(dialog, select, null);

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Die EVU wurde erfolgreich erstellt.',
      dialogTitle: 'EVU erfassen',
    });

    await expect(row.getByRole('cell', { name: TEST_CODE, exact: true })).toBeVisible();
    await expect(row.getByRole('cell', { name: TEST_SHORT_NAME, exact: true })).toBeVisible();
    await expect(
      row.getByRole('cell', { name: `${TEST_TENANT_ID} - sbb`, exact: true }),
    ).toBeVisible();

    // edit
    const editDialog = await openEditEntryDialog(page, row);
    const shortNameInput = editDialog.getByRole('textbox', { name: 'Kurzname (NeTS)' });
    await expect(shortNameInput).toHaveValue(TEST_SHORT_NAME);
    await shortNameInput.fill(TEST_SHORT_NAME_UPDATED);
    await expect(shortNameInput).toHaveValue(TEST_SHORT_NAME_UPDATED);

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Die EVU wurde erfolgreich gespeichert.',
      dialogTitle: 'EVU bearbeiten',
    });

    await expect(
      updatedRow.getByRole('cell', { name: TEST_SHORT_NAME_UPDATED, exact: true }),
    ).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, updatedRow);
  });
});
