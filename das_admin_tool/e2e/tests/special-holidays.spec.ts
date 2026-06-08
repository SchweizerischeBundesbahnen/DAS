import test, { expect, Page } from '@playwright/test';
import {
  deleteBySelecting,
  deleteEntryDialog,
  findRow,
  openEditDialog,
  selectAnyOption
} from '../utils/admin-test-helpers';

test.describe('special holidays test', () => {
  const TEST_HOLIDAY_NAME = 'E2E Special Holiday 9999';
  const TEST_VALID_DATE = '01.01.2040';


  async function createSpecialHoliday(page: Page, holidayName: string) {
    await page.getByText('Neuen Eintrag erfassen', {exact: true}).click();
    const dialog = page.locator('sbb-dialog-content');
    await expect(dialog).toBeVisible();
    const holidayNameInput = dialog.getByRole('textbox', {name: 'Name des Feiertags'});
    await expect(holidayNameInput).toBeVisible();
    await holidayNameInput.fill(holidayName);
    await expect(holidayNameInput).toHaveValue(holidayName);

    const dateInput = dialog.locator('sbb-form-field').filter({hasText: 'Gültig am'}).locator('sbb-date-input');
    await dateInput.fill(TEST_VALID_DATE);
    await expect(dateInput).toContainText('01.01.2040');

    const companyInput = page.locator('app-companies-input [role="combobox"]').last();
    await selectAnyOption(page, companyInput);

    await page.getByText('Speichern', {exact: true}).click();
    await expect(page.getByText('Speziellen Feiertag erfassen', {exact: true})).not.toBeVisible();
  }

  test.beforeEach(async ({page}) => {
    await page.goto('ru-admin/special-holidays');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Spezielle Feiertage');
  });

  test('create, edit and delete special holiday | tests: 1656', async ({page}) => {
    const addButton = page.getByText('Neuen Eintrag erfassen', {exact: true});
    await expect(addButton).toBeVisible();

    const row = findRow(page, TEST_HOLIDAY_NAME);

    // Clean up leftovers from previous run if present.
    await deleteBySelecting(page, TEST_HOLIDAY_NAME);

    // create
    await createSpecialHoliday(page, TEST_HOLIDAY_NAME);

    await expect(row).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_HOLIDAY_NAME, exact: true})).toBeVisible();

    // edit
    await openEditDialog(row);
    await page.locator('.radio-button-group').getByText('Montag', {exact: true}).click();

    await page.getByText('Weiter', {exact: true}).click();
    await page.getByText('Speichern', {exact: true}).click();

    await expect(row.getByRole('cell', {name: 'Montag', exact: true})).toBeVisible();

    // delete
    await deleteEntryDialog(page, row);
  });

  test('delete selected special holidays via checkbox | tests: 1656', async ({page}) => {
    // create one entry to select and bulk-delete
    await createSpecialHoliday(page, TEST_HOLIDAY_NAME);
    await deleteBySelecting(page, TEST_HOLIDAY_NAME);
  });
});

