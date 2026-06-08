import test, { expect, Locator, Page } from '@playwright/test';
import { findRow, openEditDialog, selectAnyOption } from '../utils/admin-test-helpers';

test.describe('ru indication templates test', () => {

  const TEST_CATEGORY = 'E2E Test Category 9999';
  const TEST_TITLE_DE = 'E2E Titel DE';
  const TEST_TEXT_DE = 'E2E Text DE';
  const TEST_TITLE_DE_UPDATED = 'E2E Titel DE aktualisiert';

  async function saveRuIndicationTemplate(page: Page, options: {
    method: 'POST' | 'PUT',
    successToast: string,
    dialogTitle: string,
  }) {
    const reloadResponse = page.waitForResponse((resp) => resp.request().method() === 'GET');
    const saveResponse = page.waitForResponse((resp) => resp.request().method() === options.method);
    if (options.method === 'PUT') {
      await page.getByText('Weiter', {exact: true}).click();
    }
    await page.getByText('Speichern', {exact: true}).click();
    await saveResponse;
    await reloadResponse;
    await expect(page.getByText(options.successToast, {exact: true})).toBeVisible();
    await expect(page.getByText(options.dialogTitle, {exact: true})).not.toBeVisible();
  }

  async function fillRuIndicationTemplateDialog(page: Page, values: {
    category?: string;
    title: string;
    text?: string
  }) {
    const categoryInput = page.getByRole('textbox', {name: 'Name der Kategorie eingeben'});
    if (values.category !== undefined) {
      await expect(categoryInput).toBeVisible();
      await categoryInput.fill(values.category);
    }
    await page.getByRole('textbox', {name: 'Titel'}).fill(values.title);
    if (values.text !== undefined) {
      await page.getByRole('textbox', {name: 'Text'}).fill(values.text)
    }
    const companyInput = page.locator('app-companies-input [role="combobox"]').last();
    await selectAnyOption(page, companyInput);
  }

  async function deleteRuIndicationTemplate(page: Page, row: Locator) {
    await openEditDialog(row);
    const deleteResponse = page.waitForResponse((resp) => resp.request().method() === 'DELETE');
    await page.getByText('Eintrag löschen', {exact: true}).click();
    await deleteResponse;
    await expect(row).not.toBeVisible();
  }

  test.beforeEach(async ({page}) => {
    await page.goto('ru-admin/ruindication-templates');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Titel und Texte');
  });

  test('create, edit and delete ru indication template | tests: 1626', async ({page}) => {
    const addButton = page.getByText('Neuen Eintrag erfassen', {exact: true});
    await expect(addButton).toBeVisible();

    const row = findRow(page, TEST_TITLE_DE);
    const updatedRow = findRow(page, TEST_TITLE_DE_UPDATED);

    // clean up leftover from previous run if present
    if (await row.isVisible()) {
      await deleteRuIndicationTemplate(page, row);
    }
    if (await updatedRow.isVisible()) {
      await deleteRuIndicationTemplate(page, updatedRow);
    }

    // create
    await addButton.click();
    await fillRuIndicationTemplateDialog(page, {
      category: TEST_CATEGORY,
      title: TEST_TITLE_DE,
      text: TEST_TEXT_DE,
    });

    await saveRuIndicationTemplate(page, {
      method: 'POST',
      successToast: 'Der Titel & Text wurde erfolgreich erstellt.',
      dialogTitle: 'Titel und Text erfassen',
    });

    await expect(row).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_CATEGORY, exact: true})).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_TITLE_DE, exact: true})).toBeVisible();

    // edit
    await openEditDialog(row);
    const deTitleInput = page.getByRole('textbox', {name: 'Titel'});
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE);
    await deTitleInput.fill(TEST_TITLE_DE_UPDATED);
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE_UPDATED);

    await saveRuIndicationTemplate(page, {
      method: 'PUT',
      successToast: 'Der Titel & Text wurde erfolgreich gespeichert.',
      dialogTitle: 'Titel und Text bearbeiten',
    });

    await expect(updatedRow).toBeVisible({timeout: 15_000});
    await expect(updatedRow.getByRole('cell', {
      name: TEST_TITLE_DE_UPDATED,
      exact: true
    })).toBeVisible();

    // delete
    await deleteRuIndicationTemplate(page, updatedRow);
  });

  test('delete selected ru indication templates | tests: 1626', async ({page}) => {
    const row = findRow(page, TEST_TITLE_DE);
    const updatedRow = findRow(page, TEST_TITLE_DE_UPDATED);

    if (await row.isVisible()) {
      await deleteRuIndicationTemplate(page, row);
    }
    if (await updatedRow.isVisible()) {
      await deleteRuIndicationTemplate(page, updatedRow);
    }

    // create one entry to select and bulk-delete
    await page.getByText('Neuen Eintrag erfassen', {exact: true}).click();
    await expect(page.getByRole('textbox', {name: 'Name der Kategorie eingeben'})).toBeVisible();
    await fillRuIndicationTemplateDialog(page, {
      category: TEST_CATEGORY,
      title: TEST_TITLE_DE,
    });

    await saveRuIndicationTemplate(page, {
      method: 'POST',
      successToast: 'Der Titel & Text wurde erfolgreich erstellt.',
      dialogTitle: 'Titel und Text erfassen',
    });

    await expect(row).toBeVisible();
    await row.locator('sbb-checkbox').click();

    const deleteAllResponse = page.waitForResponse((resp) => resp.request().method() === 'DELETE');
    await page.getByText('Eintrag löschen', {exact: true}).click();
    await deleteAllResponse;

    await expect(row).not.toBeVisible();
  });
});


