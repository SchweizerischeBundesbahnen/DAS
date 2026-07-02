import test, {expect} from '@playwright/test';
import {deleteEntryIfExists, deleteEntryViaDialog, findRow} from '../utils/admin-test-helpers';

test.describe('app versions test', () => {

  const TEST_VERSION = '9999999999.0.0';
  const TEST_DATE = '22.03.39';

  test('create, edit and delete app version | tests: 1406', async ({page}) => {
    await page.goto('das-admin');
    const addButton = page.getByText('App Version blockieren', {exact: true});

    await expect(addButton).toBeVisible();
    const row = findRow(page, TEST_VERSION);
    const editButton = row.getByRole('cell').last();

    await deleteEntryIfExists(page, row);

    // create
    await addButton.click();
    const dialog = page.locator('sbb-dialog-content');
    const versionInput = dialog.getByRole('textbox', {name: 'App Version'});
    await versionInput.fill(TEST_VERSION);
    const dateInput = dialog.locator('sbb-form-field').filter({hasText: 'Gültig ab'}).locator('sbb-date-input');
    await dateInput.fill(TEST_DATE);
    await page.getByText('Speichern', {exact: true}).click();

    await expect(row).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_VERSION, exact: true})).toBeVisible();
    await expect(row.locator('td').filter({hasText: 'Nein'})).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_DATE, exact: true})).toBeVisible();

    // edit
    await editButton.click();
    await page.locator('sbb-toggle-check').filter({hasText: 'Minimale Version'}).click();
    await page.getByText('Weiter', {exact: true}).click();
    await page.getByText('Speichern', {exact: true}).click();
    await expect(row.locator('td').filter({hasText: 'Ja'})).toBeVisible();

    await deleteEntryViaDialog(page, row);
  });
});
