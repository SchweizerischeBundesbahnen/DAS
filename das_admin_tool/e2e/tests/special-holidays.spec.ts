import test, { expect, Locator, Page } from '@playwright/test';
import {
  clickAddButton,
  deleteEntryViaDialog,
  deleteEntryViaSelection,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
  selectAnyOption,
  uniqueSuffix,
} from '../utils/admin-test-helpers';

test.describe('special holidays test', () => {
  const TEST_HOLIDAY_IS_A_UPDATED = 'Montag';
  const TEST_VALID_DATE = '01.01.2040';

  let holidayName: string;
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
    holidayName = `E2E Special Holiday ${uniqueSuffix()}`;

    await page.goto('ru-admin/special-holidays');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Spezielle Feiertage');

    row = findRow(page, holidayName);
    updatedRow = findRow(page, holidayName, TEST_HOLIDAY_IS_A_UPDATED);
  });

  test('specialHoliday_whenCreatedEditedAndDeleted_thenSucceeds|gOwwfY8O1yUCX7lueI8X|tests:1656', async ({
    page,
  }) => {
    // create
    await createSpecialHoliday(page, holidayName, TEST_VALID_DATE);

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

  test('specialHoliday_whenBulkDeleteViaCheckbox_thenDeletes|FI9uSoZiw9gE5Q14HEtg|tests:1656', async ({
    page,
  }) => {
    // create one entry to select and bulk-delete
    await createSpecialHoliday(page, holidayName, TEST_VALID_DATE);

    await deleteEntryViaSelection(page, row);
  });
});
