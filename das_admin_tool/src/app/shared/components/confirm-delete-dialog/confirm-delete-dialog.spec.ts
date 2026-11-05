import { TestBed } from '@angular/core/testing';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { ConfirmDeleteDialog, ConfirmDeleteDialogData } from './confirm-delete-dialog';

async function render(data: ConfirmDeleteDialogData): Promise<HTMLElement> {
  TestBed.configureTestingModule({
    imports: [ConfirmDeleteDialog],
    providers: [{ provide: SBB_OVERLAY_DATA, useValue: data }],
  });
  const fixture = TestBed.createComponent(ConfirmDeleteDialog);
  await fixture.whenStable();
  return fixture.nativeElement as HTMLElement;
}

describe('ConfirmDeleteDialog', () => {
  it('should ask to delete a single entry without a count', async () => {
    const element = await render({ count: 1 });

    expect(element.querySelector('sbb-dialog-title')?.textContent?.trim()).toBe('Eintrag löschen?');
  });

  it('should name the number of entries when deleting several', async () => {
    const element = await render({ count: 3 });

    expect(element.querySelector('sbb-dialog-title')?.textContent?.trim()).toBe(
      '3 Einträge löschen?',
    );
  });

  it('should mark the delete button as destructive', async () => {
    const element = await render({ count: 1 });

    const deleteButton = element.querySelector('sbb-secondary-button');
    expect(deleteButton?.textContent?.trim()).toBe('Löschen');
    expect(deleteButton?.classList).toContain('button-danger');
  });

  it('should make cancel the focused primary action', async () => {
    const element = await render({ count: 1 });

    const cancelButton = element.querySelector('sbb-button');
    expect(cancelButton?.textContent?.trim()).toBe('Abbrechen');
    expect(cancelButton?.hasAttribute('sbb-focus-initial')).toBe(true);
  });
});
