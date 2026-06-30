import test, {expect, Locator, Page} from '@playwright/test';
import {
  clickAddButton,
  deleteEntryIfExists,
  deleteEntryViaDialog,
  deleteEntryViaSelection,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
  selectAnyOption,
} from '../utils/admin-test-helpers';

test.describe('external links test', () => {
  const TEST_TITLE_DE = 'E2E External Link';
  const TEST_LINK_DE = 'https://sbb.ch';
  const TEST_TITLE_DE_UPDATED = 'E2E External Link updated';

  let row: Locator;
  let updatedRow: Locator;

  async function createExternalLink(page: Page, title: string, link: string) {
    await clickAddButton(page);

    const dialog = await getEntryDialog(page);

    await dialog.getByRole('textbox', {name: 'Titel'}).fill(title);
    await dialog.getByRole('textbox', {name: 'Webadresse (URL)'}).fill(link);

    const companyInput = dialog.locator('app-companies-input [role="combobox"]').last();
    await selectAnyOption(dialog, companyInput);

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Der externe Absprung wurde erfolgreich erstellt.',
      dialogTitle: 'Externen Absprung erfassen',
    });

    await expect(row.getByRole('cell', {name: title, exact: true})).toBeVisible();
  }

  test.beforeEach(async ({page}) => {
    await page.goto('ru-admin/external-links');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Externe Absprünge');

    row = findRow(page, TEST_TITLE_DE);
    updatedRow = findRow(page, TEST_TITLE_DE_UPDATED);

    // clean up leftover from previous run if present
    await deleteEntryIfExists(page, row);
    await deleteEntryIfExists(page, updatedRow);
  });

  test('create, edit and delete external link | tests: 246', async ({page}) => {
    // create
    await createExternalLink(page, TEST_TITLE_DE, TEST_LINK_DE);

    // edit
    const dialog = await openEditEntryDialog(page, row);
    const deTitleInput = dialog.getByRole('textbox', {name: 'Titel'});
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE);
    await deTitleInput.fill(TEST_TITLE_DE_UPDATED);
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE_UPDATED);

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Der externe Absprung wurde erfolgreich gespeichert.',
      dialogTitle: 'Externen Absprung bearbeiten',
    });

    await expect(
      updatedRow.getByRole('cell', {name: TEST_TITLE_DE_UPDATED, exact: true}),
    ).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, updatedRow);
  });

  test('delete selected external links via checkbox | tests: 246', async ({page}) => {
    // create one entry to select and bulk-delete
    await createExternalLink(page, TEST_TITLE_DE, TEST_LINK_DE);

    // delete
    await deleteEntryViaSelection(page, row);
  });
});
