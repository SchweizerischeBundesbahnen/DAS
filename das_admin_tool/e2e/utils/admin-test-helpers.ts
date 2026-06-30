import { expect, Locator, Page } from '@playwright/test';

/**
 * Generic helpers for ru admin feature tests
 */
export function findRow(page: Page, ...cellTexts: string[]): Locator {
	let loc: Locator = page.locator('tr[sbb-row]');
	for (const txt of cellTexts) {
		loc = loc.filter({ has: page.getByRole('cell', { name: txt, exact: true }) });
	}
	return loc.first();
}

export async function clickAddButton(page: Page) {
	const addButton = page.getByText('Neuen Eintrag erfassen', { exact: true });
	await expect(addButton).toBeVisible();
	await addButton.click();
}

export async function getEntryDialog(page: Page) {
	const dialog = page.locator('sbb-dialog');
	await expect(dialog).toBeVisible();
	return dialog;
}

export async function saveEntryDialog(
	page: Page,
	row: Locator,
	options: { method: 'POST' | 'PUT'; successToast: string; dialogTitle: string },
) {
	const saveResponse = page.waitForResponse((resp) => resp.request().method() === options.method);
	const reloadResponse = page.waitForResponse((resp) => resp.request().method() === 'GET');
	if (options.method === 'PUT') {
		await page.getByText('Weiter', { exact: true }).click();
	}
	await page.getByText('Speichern', { exact: true }).click();
	await saveResponse;
	await reloadResponse;
	await expect(page.getByText(options.successToast, { exact: true })).toBeVisible();
	await expect(page.getByText(options.dialogTitle, { exact: true })).not.toBeVisible();

	await expect(row).toBeVisible();
}

export async function openEditEntryDialog(page: Page, row: Locator) {
	await row.locator('sbb-mini-button').click();

	return await getEntryDialog(page);
}

export async function deleteEntryViaDialog(page: Page, row: Locator) {
	const dialog = await openEditEntryDialog(page, row);

	const deleteResponse = page.waitForResponse((resp) => resp.request().method() === 'DELETE');
	const deleteBtn = dialog.getByText('Eintrag löschen', { exact: true });
	await expect(deleteBtn).toBeVisible();
	await deleteBtn.click();
	await deleteResponse;
	await expect(row).not.toBeVisible();
}

export async function deleteEntryViaSelection(page: Page, ...rows: Locator[]) {
	if (rows.length === 0) {
		return;
	}
	for (const row of rows) {
		if (await row.isVisible()) {
			await row.locator('sbb-checkbox').click();
		}
	}
	const deleteResponse = page.waitForResponse((resp) => resp.request().method() === 'DELETE');
	await page.getByText('löschen').click();
	await deleteResponse;
	for (const row of rows) {
		await expect(row).not.toBeVisible();
	}
}

export async function selectAnyOption(dialog: Locator, inputLocator: Locator, query = '') {
	await inputLocator.click();

	await inputLocator.fill(query);

	const firstVisibleOption = dialog.locator('sbb-option:visible').first();
	await expect(firstVisibleOption).toBeVisible();
	await firstVisibleOption.click();
}
