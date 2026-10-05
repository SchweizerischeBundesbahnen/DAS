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

test.describe('ru indications test', () => {
  const TEST_TEXT_DE = 'E2E Hinweis Text DE';
  const TEST_VALID_DATE = '01.01.2040';

  let titleDe: string;
  let titleDeUpdated: string;
  let row: Locator;
  let updatedRow: Locator;

  async function createRUIndication(page: Page, title: string, text: string, date: string) {
    await clickAddButton(page);

    const dialog = await getEntryDialog(page);

    // fill title/text (DE tab is the first tab)
    await dialog.getByRole('textbox', { name: 'Titel' }).fill(title);
    await dialog.getByRole('textbox', { name: 'Text' }).fill(text);

    // next to scope
    await dialog.getByText('Weiter', { exact: true }).click();

    const companyInput = dialog.locator('app-companies-input [role="combobox"]').last();
    await selectAnyOption(dialog, companyInput);

    const locationsInput = dialog.locator('app-locations-input [role="combobox"]').last();
    await selectAnyOption(dialog, locationsInput, 'ol');

    // next to periods
    await dialog.getByText('Weiter', { exact: true }).click();

    // add a period
    const fromInput = dialog
      .locator('sbb-form-field')
      .filter({ hasText: 'Von' })
      .locator('sbb-date-input');
    await fromInput.fill(date);
    await dialog.getByText('Auswahl hinzufügen', { exact: true }).click();

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Der Hinweis wurde erfolgreich erstellt.',
      dialogTitle: 'Hinweis erfassen',
    });

    await expect(row.getByRole('cell', { name: title, exact: true })).toBeVisible();
  }

  test.beforeEach(async ({ page }) => {
    const suffix = uniqueSuffix();
    titleDe = `E2E Hinweis DE ${suffix}`;
    titleDeUpdated = `E2E Hinweis DE ${suffix} Aktualisiert`;

    await page.goto('ru-admin/ruindications');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Hinweise');

    row = findRow(page, titleDe);
    updatedRow = findRow(page, titleDeUpdated);
  });

  test('ruIndication_whenCreatedEditedAndDeleted_thenSucceeds|mAxDTAXFUf6YgD74EcqA|tests:144', async ({
    page,
  }) => {
    // create
    await createRUIndication(page, titleDe, TEST_TEXT_DE, TEST_VALID_DATE);

    // edit
    const dialog = await openEditEntryDialog(page, row);
    const deTitleInput = dialog.getByRole('textbox', { name: 'Titel' });
    await expect(deTitleInput).toHaveValue(titleDe);
    await deTitleInput.fill(titleDeUpdated);
    await expect(deTitleInput).toHaveValue(titleDeUpdated);

    // skip other steps in edit mode
    await dialog.getByText('Weiter', { exact: true }).click({ clickCount: 2 });

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Der Hinweis wurde erfolgreich gespeichert.',
      dialogTitle: 'Hinweis bearbeiten',
    });

    await expect(updatedRow.getByRole('cell', { name: titleDeUpdated, exact: true })).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, updatedRow);
  });

  test('ruIndication_whenBulkDeleteViaCheckbox_thenDeletes|qESZIrb6RHmFucd3r3B8|tests:144', async ({
    page,
  }) => {
    // create one entry to select and bulk-delete
    await createRUIndication(page, titleDe, TEST_TEXT_DE, TEST_VALID_DATE);

    // delete
    await deleteEntryViaSelection(page, row);
  });
});
