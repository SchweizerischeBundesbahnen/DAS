import { TestBed } from '@angular/core/testing';
import { SbbDialogRef } from '@sbb-esta/lyne-angular/dialog';
import { ConfirmDeleteService } from '~shared/services/confirm-delete.service';
import { BaseDialog } from './base-dialog';

const mockDialogRef = { close: vi.fn() };
const mockConfirmDeleteService = { confirm: vi.fn() };

describe('BaseDialog', () => {
  let element: HTMLElement;

  beforeEach(async () => {
    vi.clearAllMocks();
    TestBed.configureTestingModule({
      imports: [BaseDialog],
      providers: [
        { provide: SbbDialogRef, useValue: mockDialogRef },
        { provide: ConfirmDeleteService, useValue: mockConfirmDeleteService },
      ],
    });
    const fixture = TestBed.createComponent(BaseDialog);
    fixture.componentRef.setInput('dialogTitle', 'Titel');
    fixture.componentRef.setInput('stepLabel', 'Schritt');
    fixture.componentRef.setInput('data', { lastModifiedBy: 'test' });
    fixture.componentRef.setInput('saveDisabled', false);
    fixture.componentRef.setInput('dialogClose', null);
    element = fixture.nativeElement as HTMLElement;
    await fixture.whenStable();
  });

  async function clickDelete() {
    element.querySelector<HTMLElement>('sbb-transparent-button')?.click();
    await Promise.resolve();
  }

  it('should ask for confirmation of a single entry on delete', async () => {
    mockConfirmDeleteService.confirm.mockResolvedValue(false);

    await clickDelete();

    expect(mockConfirmDeleteService.confirm).toHaveBeenCalledWith(1);
  });

  it('should close the dialog with delete when confirmed', async () => {
    mockConfirmDeleteService.confirm.mockResolvedValue(true);

    await clickDelete();

    expect(mockDialogRef.close).toHaveBeenCalledWith('delete');
  });

  it('should keep the dialog open when cancelled', async () => {
    mockConfirmDeleteService.confirm.mockResolvedValue(false);

    await clickDelete();

    expect(mockDialogRef.close).not.toHaveBeenCalled();
  });
});
