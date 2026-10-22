import { randomInt } from 'node:crypto';
import test, { expect } from '@playwright/test';
import {
  clickAddButton,
  deleteEntryViaDialog,
  findRow,
  getEntryDialog,
  openEditEntryDialog,
  saveEntryDialog,
} from '../utils/admin-test-helpers';
import { AppVersionsApi } from '../utils/app-versions-api';

/**
 * Uses the highest valid major and minor with a random patch for parallel runs without collisions.
 */
function randomTestVersion(): string {
  return `99999.99999.${randomInt(0, 100_000)}`;
}

test.describe('app versions test', () => {
  const TEST_DATE = '22.03.39';
  const TEST_IS_MINIMAL = 'Nein';
  const TEST_IS_MINIMAL_UPDATED = 'Ja';

  let testVersion: string;
  let appVersionsApi: AppVersionsApi | undefined;

  test.beforeEach(async ({ page }) => {
    testVersion = randomTestVersion();
    appVersionsApi = undefined;

    const appVersionsLoaded = page.waitForResponse(
      (resp) =>
        resp.request().method() === 'GET'
        && ['xhr', 'fetch'].includes(resp.request().resourceType())
        && new URL(resp.url()).pathname.endsWith('/app-versions'),
    );
    await page.goto('das-admin/app-versions');
    appVersionsApi = await AppVersionsApi.fromListResponse(page, await appVersionsLoaded);
    await expect(page.locator('sbb-title[level="2"]')).toHaveText('Blockierte App Versionen');
    // the title renders before the data arrives, wait for rows before using the table
    await expect(page.locator('tr[sbb-row]').first()).toBeVisible();
  });

  test.afterEach(async () => {
    if (!appVersionsApi) return;

    // runs also when the test failed halfway, a leftover version would block DAS-Client usage
    const own = (await appVersionsApi.list()).find(
      (appVersion) => appVersion.version === testVersion,
    );
    if (own) await appVersionsApi.delete(own.id);
  });

  test('appVersion_whenCreatedEditedAndDeleted_thenSucceeds|2HUIAIb0FIAD3nvFwBbT|tests:1406', async ({
    page,
  }) => {
    const row = findRow(page, testVersion, TEST_IS_MINIMAL);
    const updatedRow = findRow(page, testVersion, TEST_IS_MINIMAL_UPDATED);

    // create
    await clickAddButton(page, 'App Version blockieren');

    const dialog = await getEntryDialog(page);

    await dialog.getByRole('textbox', { name: 'App Version' }).fill(testVersion);
    await dialog
      .locator('sbb-form-field')
      .filter({ hasText: 'Gültig ab' })
      .locator('sbb-date-input')
      .fill(TEST_DATE);

    await saveEntryDialog(page, row, {
      method: 'POST',
      successToast: 'Die blockierte App Version wurde erfolgreich erstellt.',
      dialogTitle: 'App Version blockieren',
    });

    await expect(row.getByRole('cell', { name: testVersion, exact: true })).toBeVisible();
    await expect(row.getByRole('cell', { name: TEST_IS_MINIMAL, exact: true })).toBeVisible();
    await expect(row.getByRole('cell', { name: TEST_DATE, exact: true })).toBeVisible();

    // edit
    const editDialog = await openEditEntryDialog(page, row);
    await editDialog.locator('sbb-toggle-check').filter({ hasText: 'Minimale Version' }).click();

    await saveEntryDialog(page, updatedRow, {
      method: 'PUT',
      successToast: 'Die blockierte App Version wurde erfolgreich gespeichert.',
      dialogTitle: 'Blockierte App Version bearbeiten',
    });

    await expect(
      updatedRow.getByRole('cell', { name: TEST_IS_MINIMAL_UPDATED, exact: true }),
    ).toBeVisible();

    // delete
    await deleteEntryViaDialog(page, updatedRow);
  });
});
