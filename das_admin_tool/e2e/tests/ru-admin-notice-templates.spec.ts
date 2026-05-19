import test, {expect, Locator, Page} from '@playwright/test';

test.describe('ru admin notice templates test', () => {

  const TEST_CATEGORY = 'E2E Test Category 9999';
  const TEST_TITLE_DE = 'E2E Titel DE';
  const TEST_TEXT_DE = 'E2E Text DE';
  const TEST_TITLE_DE_UPDATED = 'E2E Titel DE aktualisiert';

  function findRow(page: Page, title: string): Locator {
    return page.locator('tr[sbb-row]').filter({
      has: page.getByRole('cell', {name: TEST_CATEGORY, exact: true}),
    }).filter({
      has: page.getByRole('cell', {name: title, exact: true}),
    }).first();
  }

  async function openEditDialog(row: Locator) {
    await row.locator('sbb-mini-button').click();
  }

  async function saveNoticeTemplate(page: Page, options: {
    method: 'POST' | 'PUT',
    successToast: string,
    dialogTitle: string,
  }) {
    const reloadResponse = page.waitForResponse((resp) =>
      resp.request().method() === 'GET' && /\/v1\/notice-templates(\?|$)/.test(resp.url()),
    );
    const saveResponse = page.waitForResponse((resp) =>
      resp.request().method() === options.method
      && /\/v1\/notice-templates/.test(resp.url()),
    );
    await page.getByText('Speichern', {exact: true}).click();
    await saveResponse;
    await reloadResponse;
    await expect(page.getByText(options.successToast, {exact: true})).toBeVisible();
    await expect(page.getByText(options.dialogTitle, {exact: true})).not.toBeVisible();
  }

  async function fillNoticeTemplateDialog(page: Page, values: { category?: string; title: string; text?: string }) {
    if (values.category !== undefined) {
      await expect(page.locator('#category')).toBeVisible();
      await page.locator('#category').fill(values.category);
    }
    await page.locator('#deTitle').fill(values.title);
    if (values.text !== undefined) {
      await page.locator('#deText').fill(values.text);
    }
  }

  async function deleteNoticeTemplate(page: Page, row: Locator) {
    await openEditDialog(row);
    const deleteResponse = page.waitForResponse((resp) =>
      resp.request().method() === 'DELETE' && resp.url().includes('/v1/notice-templates/'),
    );
    await page.getByText('Titel und Text löschen', {exact: true}).click();
    await deleteResponse;
    await expect(row).not.toBeVisible();
  }

  test.beforeEach(async ({page}) => {
    await page.goto('ru-admin/notice-templates');
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Titel und Texte');
  });

  test('create, edit and delete notice template | tests: 1626', async ({page}) => {
    const addButton = page.getByText('Neuen Eintrag erfassen', {exact: true});
    await expect(addButton).toBeVisible();

    const row = findRow(page, TEST_TITLE_DE);
    const updatedRow = findRow(page, TEST_TITLE_DE_UPDATED);

    // clean up leftover from previous run if present
    if (await row.isVisible()) {
      await deleteNoticeTemplate(page, row);
    }
    if (await updatedRow.isVisible()) {
      await deleteNoticeTemplate(page, updatedRow);
    }

    // create
    await addButton.click();
    await fillNoticeTemplateDialog(page, {
      category: TEST_CATEGORY,
      title: TEST_TITLE_DE,
      text: TEST_TEXT_DE,
    });

    await saveNoticeTemplate(page, {
      method: 'POST',
      successToast: 'Der Titel & Text wurde erfolgreich erstellt.',
      dialogTitle: 'Titel und Text erfassen',
    });

    await expect(row).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_CATEGORY, exact: true})).toBeVisible();
    await expect(row.getByRole('cell', {name: TEST_TITLE_DE, exact: true})).toBeVisible();

    // edit
    await openEditDialog(row);
    const deTitleInput = page.locator('#deTitle');
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE);
    await deTitleInput.fill(TEST_TITLE_DE_UPDATED);
    await expect(deTitleInput).toHaveValue(TEST_TITLE_DE_UPDATED);

    await saveNoticeTemplate(page, {
      method: 'PUT',
      successToast: 'Der Titel & Text wurde erfolgreich gespeichert.',
      dialogTitle: 'Titel und Text bearbeiten',
    });

    await expect(updatedRow).toBeVisible({timeout: 15_000});
    await expect(updatedRow.getByRole('cell', {name: TEST_TITLE_DE_UPDATED, exact: true})).toBeVisible();

    // delete
    await deleteNoticeTemplate(page, updatedRow);
  });

  test('delete selected notice templates | tests: 1626', async ({page}) => {
    const row = findRow(page, TEST_TITLE_DE);
    const updatedRow = findRow(page, TEST_TITLE_DE_UPDATED);

    if (await row.isVisible()) {
      await deleteNoticeTemplate(page, row);
    }
    if (await updatedRow.isVisible()) {
      await deleteNoticeTemplate(page, updatedRow);
    }

    // create one entry to select and bulk-delete
    await page.getByText('Neuen Eintrag erfassen', {exact: true}).click();
    await expect(page.getByRole('textbox', {name: 'Name der Kategorie eingeben'})).toBeVisible();
    await fillNoticeTemplateDialog(page, {
      category: TEST_CATEGORY,
      title: TEST_TITLE_DE,
    });

    await saveNoticeTemplate(page, {
      method: 'POST',
      successToast: 'Der Titel & Text wurde erfolgreich erstellt.',
      dialogTitle: 'Titel und Text erfassen',
    });

    await expect(row).toBeVisible();
    await row.locator('sbb-checkbox').click();

    const deleteAllResponse = page.waitForResponse((resp) =>
      resp.request().method() === 'DELETE' && /\/v1\/notice-templates$/.test(resp.url()),
    );
    await page.getByText('Eintrag löschen', {exact: true}).click();
    await deleteAllResponse;

    await expect(row).not.toBeVisible();
  });
});


