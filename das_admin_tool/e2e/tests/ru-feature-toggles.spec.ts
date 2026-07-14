import test, {expect} from '@playwright/test';
import {
  clickAddButton,
  deleteEntryIfExists,
  deleteEntryViaDialog,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
  selectAnyOption,
} from '../utils/admin-test-helpers';

test.describe('ru feature toggles test', () => {
  const TEST_FEATURE_KEY = 'CHECKLIST_DEPARTURE_PROCESS';

  test('create, edit and delete ru feature toggle | tests: 2416', async ({page}) => {
    await page.goto('ru-admin/ru-features');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('RU Feature Toggles');

    // pick an available company without saving, just to know which row to look for / clean up
    await clickAddButton(page);
    const probeDialog = await getEntryDialog(page);
    const probeCompanyInput = probeDialog.getByRole('combobox', {name: 'EVU'});
    await selectAnyOption(probeDialog, probeCompanyInput);
    const selectedCompany = await probeCompanyInput.inputValue();
    await probeDialog.getByText('Abbrechen', {exact: true}).click();
    await expect(probeDialog).not.toBeVisible();

    const row = findRow(page, selectedCompany, TEST_FEATURE_KEY);
    await deleteEntryIfExists(page, row);

    // create
    await clickAddButton(page);
    const dialog = await getEntryDialog(page);
    const companyInput = dialog.getByRole('combobox', {name: 'EVU'});
    await selectAnyOption(dialog, companyInput, selectedCompany);
    await dialog.locator('.radio-button-group').getByText(TEST_FEATURE_KEY, {exact: true}).click();

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Der Feature Toggle wurde erfolgreich erstellt.',
      dialogTitle: 'RU Feature Toggle erfassen',
    });

    await expect(row.getByRole('cell', {name: TEST_FEATURE_KEY, exact: true})).toBeVisible();
    await expect(row.locator('td').filter({hasText: 'Nein'})).toBeVisible();

    // edit
    const editDialog = await openEditEntryDialog(page, row);
    await editDialog.locator('sbb-toggle-check').filter({hasText: 'Aktiviert'}).click();
    await saveEntryDialog(page, row, {
      method: 'PUT',
      successToast: 'Der Feature Toggle wurde erfolgreich gespeichert.',
      dialogTitle: 'RU Feature Toggle bearbeiten',
    });

    await expect(row.locator('td').filter({hasText: 'Ja'})).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, row);
  });
});
