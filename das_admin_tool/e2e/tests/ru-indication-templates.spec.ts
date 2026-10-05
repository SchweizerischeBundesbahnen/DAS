import test, { expect, Locator, Page } from '@playwright/test';
import {
  clickAddButton,
  deleteEntryViaDialog,
  deleteEntryViaSelection,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
  uniqueSuffix,
} from '../utils/admin-test-helpers';

test.describe('ru indication templates test', () => {
  const TEST_CATEGORY = 'E2E Test Category 9999';
  const TEST_TEXT_DE = 'E2E Text DE';

  let titleDe: string;
  let titleDeUpdated: string;
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

    await dialog.getByRole('textbox', { name: 'Name der Kategorie eingeben' }).fill(category);

    await dialog.getByRole('textbox', { name: 'Titel' }).fill(title);

    await dialog.getByRole('textbox', { name: 'Text' }).fill(text);

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Der Titel & Text wurde erfolgreich erstellt.',
      dialogTitle: 'Titel und Text erfassen',
    });

    await expect(row.getByRole('cell', { name: category, exact: true })).toBeVisible();
    await expect(row.getByRole('cell', { name: title, exact: true })).toBeVisible();
  }

  test.beforeEach(async ({ page }) => {
    const suffix = uniqueSuffix();
    titleDe = `E2E Titel DE ${suffix}`;
    titleDeUpdated = `E2E Titel DE ${suffix} aktualisiert`;

    await page.goto('ru-admin/ruindication-templates');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Titel und Texte');

    row = findRow(page, titleDe);
    updatedRow = findRow(page, titleDeUpdated);
  });

  test('ruIndicationTemplate_whenCreatedEditedAndDeleted_thenSucceeds|rHW2EVKOiAuStBxcRSyj|tests:1626', async ({
    page,
  }) => {
    // create
    await createRuIndicationTemplate(page, TEST_CATEGORY, titleDe, TEST_TEXT_DE);

    // edit
    const dialog = await openEditEntryDialog(page, row);
    const deTitleInput = dialog.getByRole('textbox', { name: 'Titel' });
    await expect(deTitleInput).toHaveValue(titleDe);
    await deTitleInput.fill(titleDeUpdated);
    await expect(deTitleInput).toHaveValue(titleDeUpdated);

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Der Titel & Text wurde erfolgreich gespeichert.',
      dialogTitle: 'Titel und Text bearbeiten',
    });

    await expect(updatedRow.getByRole('cell', { name: titleDeUpdated, exact: true })).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, updatedRow);
  });

  test('ruIndicationTemplate_whenBulkDeleteViaCheckbox_thenDeletes|mo4pi2S61wjikk9S1tZZ|tests:1626', async ({
    page,
  }) => {
    // create one entry to select and bulk-delete
    await createRuIndicationTemplate(page, TEST_CATEGORY, titleDe, TEST_TEXT_DE);

    // delete
    await deleteEntryViaSelection(page, row);
  });
});
