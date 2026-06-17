import test, { expect, Locator, Page } from '@playwright/test';
import {
  clickAddButton,
  deleteEntryViaDialog,
  deleteEntryViaSelection,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
  selectAnyOption
} from '../utils/admin-test-helpers';

test.describe('ru indication templates test', () => {
  const TEST_CATEGORY = 'E2E Test Category 9999';
  const TEST_TITLE_DE = 'E2E Titel DE';
  const TEST_TEXT_DE = 'E2E Text DE';
  const TEST_TITLE_DE_UPDATED = 'E2E Titel DE aktualisiert';

  let row: Locator;
  let updatedRow: Locator;

  async function createRuIndicationTemplate(
    page: Page,
    category: string,
    title: string,
    text: string,
  ) {
    await clickAddButton(page);

    const dialog = await getEntryDialog(page);

    await dialog.getByRole('textbox', {name: 'Name der Kategorie eingeben'}).fill(category);

    await dialog.getByRole('textbox', {name: 'Titel'}).fill(title);

    await dialog.getByRole('textbox', {name: 'Text'}).fill(text);

    const companyInput = page.locator('app-companies-input [role="combobox"]').last();
    await selectAnyOption(dialog, companyInput);

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Der Titel & Text wurde erfolgreich erstellt.',
      dialogTitle: 'Titel und Text erfassen',
    });

    await expect(row.getByRole('cell', {name: category, exact: true})).toBeVisible();
    await expect(row.getByRole('cell', {name: title, exact: true})).toBeVisible();
  }

  test.beforeEach(async ({page}) => {
    await page.goto('ru-admin/ruindication-templates');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Titel und Texte');

    row = findRow(page, TEST_TITLE_DE);
    updatedRow = findRow(page, TEST_TITLE_DE_UPDATED);

    // clean up leftover from previous run if present
    if (await row.isVisible()) {
      await deleteEntryViaDialog(page, row);
    }
    if (await updatedRow.isVisible()) {
      await deleteEntryViaDialog(page, updatedRow);
    }
  });

  test('create, edit and delete ru indication template | tests: 1626', async ({page}) => {
    // create
    await createRuIndicationTemplate(page, TEST_CATEGORY, TEST_TITLE_DE, TEST_TEXT_DE);

    // edit
    const dialog = await openEditEntryDialog(page, row);
    const deTitleInput = dialog.getByRole('textbox', {name: 'Titel'});
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE);
    await deTitleInput.fill(TEST_TITLE_DE_UPDATED);
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE_UPDATED);

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Der Titel & Text wurde erfolgreich gespeichert.',
      dialogTitle: 'Titel und Text bearbeiten',
    });

    await expect(
      updatedRow.getByRole('cell', {name: TEST_TITLE_DE_UPDATED, exact: true}),
    ).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, updatedRow);
  });

  test('delete selected ru indication templates | tests: 1626', async ({page}) => {
    // create one entry to select and bulk-delete
    await createRuIndicationTemplate(page, TEST_CATEGORY, TEST_TITLE_DE, TEST_TEXT_DE);

    // delete
    await deleteEntryViaSelection(page, row);
  });
});
