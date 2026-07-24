import test, { expect } from '@playwright/test';
import {
  clickAddButton,
  deleteEntryIfExists,
  deleteEntryViaDialog,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
} from '../utils/admin-test-helpers';

test.describe('app versions test', () => {
  const TEST_VERSION = '9999999999.0.0';
  const TEST_DATE = '22.03.39';
  const TEST_IS_MINIMAL = 'Nein';
  const TEST_IS_MINIMAL_UPDATED = 'Ja';

  test('create, edit and delete app version | tests: 1406', async ({ page }) => {
    await page.goto('das-admin/app-versions');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Blockierte App Versionen');

    const row = findRow(page, TEST_IS_MINIMAL);
    const updatedRow = findRow(page, TEST_IS_MINIMAL_UPDATED);

    // clean up leftover from previous run if present
    await deleteEntryIfExists(page, row);
    await deleteEntryIfExists(page, updatedRow);

    // create
    await clickAddButton(page, 'App Version blockieren');

    const dialog = await getEntryDialog(page);

    await dialog.getByRole('textbox', { name: 'App Version' }).fill(TEST_VERSION);
    await dialog
      .locator('sbb-form-field')
      .filter({ hasText: 'Gültig ab' })
      .locator('sbb-date-input')
      .fill(TEST_DATE);

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Die blockierte App Version wurde erfolgreich erstellt.',
      dialogTitle: 'App Version blockieren',
    });

    await expect(row.getByRole('cell', { name: TEST_VERSION, exact: true })).toBeVisible();
    await expect(row.getByRole('cell', { name: TEST_IS_MINIMAL, exact: true })).toBeVisible();
    await expect(row.getByRole('cell', { name: TEST_DATE, exact: true })).toBeVisible();

    // edit
    const editDialog = await openEditEntryDialog(page, row);
    await editDialog.locator('sbb-toggle-check').filter({ hasText: 'Minimale Version' }).click();

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Die blockierte App Version wurde erfolgreich gespeichert.',
      dialogTitle: 'Blockierte App Version bearbeiten',
    });

    await expect(
      updatedRow.getByRole('cell', { name: TEST_IS_MINIMAL_UPDATED, exact: true }),
    ).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, updatedRow);
  });
});
