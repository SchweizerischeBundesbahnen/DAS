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

test.describe('external links test', () => {
  const TEST_LINK_DE = 'https://sbb.ch';

  let titleDe: string;
  let titleDeUpdated: string;
  let row: Locator;
  let updatedRow: Locator;

  async function createExternalLink(page: Page, title: string, link: string) {
    await clickAddButton(page);

    const dialog = await getEntryDialog(page);

    await dialog.getByRole('textbox', { name: 'Titel' }).fill(title);
    await dialog.getByRole('textbox', { name: 'Webadresse (URL)' }).fill(link);

    const companyInput = dialog.locator('app-companies-input [role="combobox"]').last();
    await selectAnyOption(dialog, companyInput);

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Der externe Absprung wurde erfolgreich erstellt.',
      dialogTitle: 'Externen Absprung erfassen',
    });

    await expect(row.getByRole('cell', { name: title, exact: true })).toBeVisible();
  }

  test.beforeEach(async ({ page }) => {
    const suffix = uniqueSuffix();
    titleDe = `E2E External Link ${suffix}`;
    titleDeUpdated = `E2E External Link ${suffix} updated`;

    await page.goto('ru-admin/external-links');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Externe Absprünge');

    row = findRow(page, titleDe);
    updatedRow = findRow(page, titleDeUpdated);
  });

  test('externalLink_whenCreatedEditedAndDeleted_thenSucceeds|3oqvaicqZm32b1jMwgdE|tests:246', async ({
    page,
  }) => {
    // create
    await createExternalLink(page, titleDe, TEST_LINK_DE);

    // edit
    const dialog = await openEditEntryDialog(page, row);
    const deTitleInput = dialog.getByRole('textbox', { name: 'Titel' });
    await expect(deTitleInput).toHaveValue(titleDe);
    await deTitleInput.fill(titleDeUpdated);
    await expect(deTitleInput).toHaveValue(titleDeUpdated);

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Der externe Absprung wurde erfolgreich gespeichert.',
      dialogTitle: 'Externen Absprung bearbeiten',
    });

    await expect(updatedRow.getByRole('cell', { name: titleDeUpdated, exact: true })).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, updatedRow);
  });

  test('externalLink_whenBulkDeleteViaCheckbox_thenDeletes|0NB8SUUOtib4On4Hdi7x|tests:246', async ({
    page,
  }) => {
    // create one entry to select and bulk-delete
    await createExternalLink(page, titleDe, TEST_LINK_DE);

    // delete
    await deleteEntryViaSelection(page, row);
  });
});
