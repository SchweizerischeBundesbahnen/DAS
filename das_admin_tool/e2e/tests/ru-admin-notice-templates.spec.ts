import test, {expect, Locator, Page} from '@playwright/test';

test.describe('admin notice templates test', () => {

  const TEST_CATEGORY = 'E2E Test Category 9999';
  const TEST_TITLE_DE = 'E2E Titel DE';
  const TEST_TEXT_DE = 'E2E Text DE';
  const TEST_TITLE_DE_UPDATED = 'E2E Titel DE aktualisiert';

  async function findRow(page: Page) {
    return page.locator('tr[sbb-row]').filter({
      has: page.getByRole('cell', {name: TEST_CATEGORY, exact: true}),
    });
  }

  async function openEditDialog(row: Locator) {
    await row.locator('sbb-mini-button').click();
  }

  async function deleteNoticeTemplate(page: Page, row: Locator) {
    await openEditDialog(row);
    const deleteResponse = page.waitForResponse((resp) => resp.request().method() === 'DELETE');
    await page.getByText('Titel und Text löschen', {exact: true}).click();
    await deleteResponse;
    await expect(row).not.toBeVisible();
  }

  test.beforeEach(async ({page}) => {
    await page.goto('ru-admin');
    await page.getByText('Titel und Texte', {exact: true}).first().click();
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Titel und Texte');
  });

  test('create, edit and delete notice template | tests: 1626', async ({page}) => {
    const addButton = page.getByText('Neuen Eintrag erfassen', {exact: true});
    await expect(addButton).toBeVisible();

    const row = await findRow(page);

    // clean up leftover from previous run if present
    if (await row.isVisible()) {
      await deleteNoticeTemplate(page, row);
    }

    // create
    await addButton.click();
    await page.locator('#category').fill(TEST_CATEGORY);
    await page.locator('#deTitle').fill(TEST_TITLE_DE);
    await page.locator('#deText').fill(TEST_TEXT_DE);

    // const createResponse = page.waitForResponse((resp) => resp.request().method() === 'POST');
    await page.getByText('Speichern', {exact: true}).click();

    await expect(row).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_CATEGORY, exact: true})).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_TITLE_DE, exact: true})).toBeVisible();

    // edit
    await openEditDialog(row);
    await page.locator('#deTitle').clear();
    await page.locator('#deTitle').fill(TEST_TITLE_DE_UPDATED);

    await page.getByText('Speichern', {exact: true}).click();

    await expect(row.getByRole('cell', {name: TEST_TITLE_DE_UPDATED, exact: true})).toBeVisible();

    // delete
    await deleteNoticeTemplate(page, row);
  });

  test('delete selected notice templates | tests: 1626', async ({page}) => {
    const addButton = page.getByText('Neuen Eintrag erfassen', {exact: true});
    const row = await findRow(page);

    if (await row.isVisible()) {
      await deleteNoticeTemplate(page, row);
    }

    // create one entry to select and bulk-delete
    await addButton.click();
    await page.locator('#category').fill(TEST_CATEGORY);
    await page.locator('#deTitle').fill(TEST_TITLE_DE);

    await page.getByText('Speichern', {exact: true}).click();

    await expect(row).toBeVisible();

    // select row via checkbox
    await row.locator('sbb-checkbox').click();

    await page.getByText('Einträge löschen', {exact: true}).click();

    await expect(row).not.toBeVisible();
  });
});


