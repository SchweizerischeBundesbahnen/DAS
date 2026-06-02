import test, { expect } from '@playwright/test';
import {
  deleteEntryDialog,
  findRow,
  openEditDialog,
  selectAnyOption
} from '../utils/admin-test-helpers';

test.describe('ru indications test', () => {

  const TEST_TITLE_DE = 'E2E Hinweis DE 9999';
  const TEST_TEXT_DE = 'E2E Hinweis Text DE';
  const TEST_TITLE_DE_UPDATED = 'E2E Hinweis DE 9999 Aktualisiert';
  const TEST_VALID_DATE = '01.01.2040';

  test.beforeEach(async ({page}) => {
    await page.goto('ru-admin/indications');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Hinweise');
  });

  test('create, edit and delete ru indication | tests: 144', async ({page}) => {
    const addButton = page.getByText('Neuen Hinweis erfassen', {exact: true});
    await expect(addButton).toBeVisible();

    const row = findRow(page, TEST_TITLE_DE);
    const updatedRow = findRow(page, TEST_TITLE_DE_UPDATED);

    // clean up leftovers from previous run if present
    if (await row.isVisible()) {
      await deleteEntryDialog(page, row);
    }
    if (await updatedRow.isVisible()) {
      await deleteEntryDialog(page, updatedRow);
    }

    // create
    await addButton.click();
    const dialog = page.locator('sbb-dialog');

    // fill title/text (DE tab is the first tab)
    await expect(dialog.getByRole('textbox', {name: 'Titel'})).toBeVisible();
    await dialog.getByRole('textbox', {name: 'Titel'}).fill(TEST_TITLE_DE);
    await dialog.getByRole('textbox', {name: 'Text'}).fill(TEST_TEXT_DE);

    // next to scope
    await dialog.getByText('Weiter', {exact: true}).click();

    const companyInput = page.locator('app-companies-input [role="combobox"]').last();
    await selectAnyOption(page, companyInput)

    const locationsInput = page.locator('app-locations-input [role="combobox"]').last();
    await selectAnyOption(page, locationsInput, 'ol');

    // next to periods
    await dialog.getByText('Weiter', {exact: true}).click();

    // add a period
    const fromInput = dialog.locator('sbb-form-field').filter({hasText: 'Von'}).locator('sbb-date-input');
    await fromInput.fill(TEST_VALID_DATE);
    await dialog.getByText('Auswahl hinzufügen', {exact: true}).click();

    // save - wait for POST and reload GET
    const reloadResponse = page.waitForResponse((resp) =>
      resp.request().method() === 'GET' && /\/v1\/ruindications(\?|$)/.test(resp.url()),
    );
    const saveResponse = page.waitForResponse((resp) =>
      resp.request().method() === 'POST' && /\/v1\/ruindications/.test(resp.url()),
    );
    await dialog.getByText('Speichern', {exact: true}).click();
    await saveResponse;
    await reloadResponse;

    await expect(page.getByText('Der Hinweis wurde erfolgreich erstellt.', {exact: true})).toBeVisible();
    await expect(row).toBeVisible();

    // edit
    await openEditDialog(row);
    const deTitleInput = page.getByRole('textbox', {name: 'Titel'});
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE);
    await deTitleInput.fill(TEST_TITLE_DE_UPDATED);
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE_UPDATED);

    // skip other steps in edit mode
    await dialog.getByText('Weiter', {exact: true}).click({clickCount: 3});

    const saveEditResponse = page.waitForResponse((resp) =>
      resp.request().method() === 'PUT' && /\/v1\/ruindications/.test(resp.url()),
    );
    const reloadAfterEdit = page.waitForResponse((resp) =>
      resp.request().method() === 'GET' && /\/v1\/ruindications(\?|$)/.test(resp.url()),
    );
    await page.getByText('Speichern', {exact: true}).click();
    await saveEditResponse;
    await reloadAfterEdit;

    await expect(updatedRow).toBeVisible({timeout: 15_000});
    await expect(updatedRow.getByRole('cell', {
      name: TEST_TITLE_DE_UPDATED,
      exact: true
    })).toBeVisible();

    // delete
    await deleteEntryDialog(page, updatedRow);
  });

  test('delete selected ru indications via checkbox | tests: 144', async ({page}) => {
    const row = findRow(page, TEST_TITLE_DE);

    if (await row.isVisible()) {
      await deleteEntryDialog(page, row);
    }

    // create one entry to select and bulk-delete
    await page.getByText('Neuen Hinweis erfassen', {exact: true}).click();
    const dialog = page.locator('sbb-dialog');
    await expect(dialog.getByRole('textbox', {name: 'Titel'})).toBeVisible();
    await dialog.getByRole('textbox', {name: 'Titel'}).fill(TEST_TITLE_DE);

    await dialog.getByText('Weiter', {exact: true}).click();
    const companyInput = page.locator('app-companies-input [role="combobox"]').last();
    await selectAnyOption(page, companyInput)
    const locationsInput = page.locator('app-locations-input [role="combobox"]').last();
    await selectAnyOption(page, locationsInput, 'aa');
    await dialog.getByText('Weiter', {exact: true}).click();
    const fromInput = dialog.locator('sbb-form-field').filter({hasText: 'Von'}).locator('sbb-date-input');
    await fromInput.fill(TEST_VALID_DATE);
    await dialog.getByText('Auswahl hinzufügen', {exact: true}).click();

    const saveResponse = page.waitForResponse((resp) => resp.request().method() === 'POST');
    await dialog.getByText('Speichern', {exact: true}).click();
    await saveResponse;

    await expect(row).toBeVisible();
    await row.locator('sbb-checkbox').click();

    const deleteResponse = page.waitForResponse((resp) => resp.request().method() === 'DELETE');
    await page.getByText('Eintrag löschen', {exact: true}).click();
    await deleteResponse;

    await expect(row).not.toBeVisible();
  });

});


