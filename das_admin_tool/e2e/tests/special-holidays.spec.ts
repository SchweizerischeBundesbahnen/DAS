import test, { expect, Locator, Page } from '@playwright/test';
import {
  clickAddButton,
  getEntryDialog,
  deleteEntryViaSelection,
  deleteEntryViaDialog,
  findRow,
  openEditEntryDialog,
  saveEntryDialog,
  selectAnyOption,
} from '../utils/admin-test-helpers';

test.describe('special holidays test', () => {
  const TEST_HOLIDAY_NAME = 'E2E Special Holiday 9999';
  const TEST_HOLIDAY_IS_A_UPDATED = 'Montag';
  const TEST_VALID_DATE = '01.01.2040';

  let row: Locator;
  let updatedRow: Locator;

  async function createSpecialHoliday(page: Page, name: string, date: string) {
    await clickAddButton(page);

    const dialog = await getEntryDialog(page);

    await dialog.getByRole('textbox', { name: 'Name des Feiertags' }).fill(name);

    await dialog
      .locator('sbb-form-field')
      .filter({ hasText: 'Gültig am' })
      .locator('sbb-date-input')
      .fill(date);

    const companyInput = dialog.locator('app-companies-input [role="combobox"]').last();
    await selectAnyOption(dialog, companyInput);

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Der Feiertag wurde erfolgreich erstellt.',
      dialogTitle: 'Speziellen Feiertag erfassen',
    });

    await expect(row.getByRole('cell', { name: name, exact: true })).toBeVisible();
  }

  test.beforeEach(async ({ page }) => {
    await page.goto('ru-admin/special-holidays');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Spezielle Feiertage');

    row = findRow(page, TEST_HOLIDAY_NAME);
    updatedRow = findRow(page, TEST_HOLIDAY_IS_A_UPDATED);

    // clean up leftover from previous run if present
    if (await row.isVisible()) {
      await deleteEntryViaDialog(page, row);
    }
    if (await updatedRow.isVisible()) {
      await deleteEntryViaDialog(page, updatedRow);
    }
  });

  test('create, edit and delete special holiday | tests: 1656', async ({ page }) => {
    // create
    await createSpecialHoliday(page, TEST_HOLIDAY_NAME, TEST_VALID_DATE);

    // edit
    const dialog = await openEditEntryDialog(page, row);
    await dialog.locator('.radio-button-group').getByText('Montag', { exact: true }).click();

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Der Feiertag wurde erfolgreich gespeichert.',
      dialogTitle: 'Speziellen Feiertag bearbeiten',
    });

    await expect(
      updatedRow.getByRole('cell', { name: TEST_HOLIDAY_IS_A_UPDATED, exact: true }),
    ).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, row);
  });

  test('delete selected special holidays via checkbox | tests: 1656', async ({ page }) => {
    // create one entry to select and bulk-delete
    await createSpecialHoliday(page, TEST_HOLIDAY_NAME, TEST_VALID_DATE);

    await deleteEntryViaSelection(page, row);
  });
});
