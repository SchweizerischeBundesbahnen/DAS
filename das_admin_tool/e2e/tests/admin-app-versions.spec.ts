import test, {expect, Locator, Page} from '@playwright/test';

test.describe('admin app versions test', () => {

  const TEST_VERSION = '9999999999.0.0';
  const TEST_DATE = '22.03.39';

  async function deleteAppVersion(page: Page, row: Locator, editButton: Locator) {
    await editButton.click();

    const deleteResponse = page.waitForResponse((resp) => resp.request().method() === 'DELETE');
    await page.getByText('Blockierte App Version löschen', {exact: true}).click();
    await deleteResponse;
    await expect(row).not.toBeVisible();
  }

  test('create, edit and delete app version | tests: 1406', async ({page}) => {
    await page.goto('');
    const addButton = page.getByText('App Version blockieren', {exact: true});

    await expect(addButton).toBeVisible();
    const row = page.locator('tr[sbb-row]').filter({
      has: page.getByRole('cell', {name: TEST_VERSION, exact: true}),
    });
    const editButton = row.getByRole('cell').last();

    if (await row.isVisible()) {
      await deleteAppVersion(page, row, editButton);
    }

    // create
    await addButton.click();
    const versionInput = page.getByRole('textbox', {name: 'App Version'});
    await versionInput.fill(TEST_VERSION);
    await page.locator('#expiryDate').fill(TEST_DATE);
    await page.getByText('Speichern', {exact: true}).click();

    await expect(row).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_VERSION, exact: true})).toBeVisible();
    await expect(row.locator('td').filter({hasText: 'Nein'})).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_DATE, exact: true})).toBeVisible();


    // edit
    await editButton.click();
    await page.locator('sbb-toggle-check').filter({hasText: 'Minimale Version'}).click();
    await page.getByText('Speichern', {exact: true}).click();
    await expect(row.locator('td').filter({hasText: 'Ja'})).toBeVisible();

    await deleteAppVersion(page, row, editButton);
  });
});
