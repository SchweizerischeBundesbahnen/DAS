import test, {expect, Locator, Page} from '@playwright/test';

test.describe('admin holidays test', () => {
  const TEST_HOLIDAY_NAME = 'E2E Special Holiday 9999';
  const TEST_HOLIDAY_NAME_UPDATED = 'E2E Special Holiday 9999 Updated';
  const TEST_VALID_DATE = '01.01.2040';

  function findRow(page: Page, holidayName: string): Locator {
    return page.locator('tr[sbb-row]').filter({
      has: page.getByRole('cell', {name: holidayName, exact: true}),
    }).first();
  }

  async function openEditDialog(row: Locator) {
    await row.locator('sbb-mini-button').click();
  }

  async function selectAnyCompany(page: Page) {
    const companyInput = page.locator('app-companies-input [role="combobox"]').last();
    await companyInput.click();

    // Use a broad query so autocomplete reliably shows at least one company.
    await companyInput.fill('a');
    const firstOption = page.locator('sbb-option').first();
    await expect(firstOption).toBeVisible();
    await firstOption.click();

    await expect(page.locator('app-companies-input sbb-chip').first()).toBeVisible();
  }

  async function deleteHoliday(page: Page, row: Locator) {
    await openEditDialog(row);
    const deleteResponse = page.waitForResponse((resp) =>
      resp.request().method() === 'DELETE' && resp.url().includes('/v1/holidays/'),
    );
    await page.getByText('Feiertag löschen', {exact: true}).click();
    await deleteResponse;
    await expect(row).not.toBeVisible();
  }

  async function createHoliday(page: Page, holidayName: string) {
    await page.getByText('Neuen Eintrag erfassen', {exact: true}).click();
    const holidayNameInput = page.locator('#holidayName').last();
    await expect(holidayNameInput).toBeVisible();
    await holidayNameInput.fill(holidayName);
    await expect(holidayNameInput).toHaveValue(holidayName);

    const validAtInput = page.locator('#validAt').last();
    await validAtInput.fill(TEST_VALID_DATE);
    await expect(validAtInput).toContainText('01.01.2040');
    await selectAnyCompany(page);

    await page.getByText('Speichern', {exact: true}).click();
    await expect(page.getByText('Speziellen Feiertag erfassen', {exact: true})).not.toBeVisible();
  }

  test.beforeEach(async ({page}) => {
    await page.goto('ru-admin/holidays');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Spezielle Feiertage');
  });

  test('create, edit and delete holiday | tests: 1656', async ({page}) => {
    const addButton = page.getByText('Neuen Eintrag erfassen', {exact: true});
    await expect(addButton).toBeVisible();

    const row = findRow(page, TEST_HOLIDAY_NAME);
    const updatedRow = findRow(page, TEST_HOLIDAY_NAME_UPDATED);

    // Clean up leftovers from previous run if present.
    if (await row.isVisible()) {
      await deleteHoliday(page, row);
    }
    if (await updatedRow.isVisible()) {
      await deleteHoliday(page, updatedRow);
    }

    // create
    await createHoliday(page, TEST_HOLIDAY_NAME);

    await expect(row).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_HOLIDAY_NAME, exact: true})).toBeVisible();

    // edit
    await openEditDialog(row);
    await page.locator('.radio-button-group').getByText('Montag', {exact: true}).click();

    await page.getByText('Speichern', {exact: true}).click();

    await expect(row.getByRole('cell', {name: 'Montag', exact: true})).toBeVisible();

    // delete
    await deleteHoliday(page, row);
  });

  test('delete selected holidays | tests: 1656', async ({page}) => {
    const row = findRow(page, TEST_HOLIDAY_NAME);
    const updatedRow = findRow(page, TEST_HOLIDAY_NAME_UPDATED);

    if (await row.isVisible()) {
      await deleteHoliday(page, row);
    }
    if (await updatedRow.isVisible()) {
      await deleteHoliday(page, updatedRow);
    }

    // create one entry to select and bulk-delete
    await createHoliday(page, TEST_HOLIDAY_NAME);

    await expect(row).toBeVisible();

    // select row via checkbox
    await row.locator('sbb-checkbox').click();

    const deleteResponse = page.waitForResponse((resp) =>
      resp.request().method() === 'DELETE' && /\/v1\/holidays$/.test(resp.url()),
    );
    await page.getByText('Einträge löschen', {exact: true}).click();
    await deleteResponse;

    await expect(row).not.toBeVisible();
  });
});

