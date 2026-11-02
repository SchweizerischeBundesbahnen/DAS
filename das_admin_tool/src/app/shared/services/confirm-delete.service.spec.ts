import { TestBed } from '@angular/core/testing';
import { SbbDialogService } from '@sbb-esta/lyne-angular/dialog';
import { of } from 'rxjs';
import { ConfirmDeleteDialog } from '~shared/components/confirm-delete-dialog/confirm-delete-dialog';
import { ConfirmDeleteService } from './confirm-delete.service';

describe('ConfirmDeleteService', () => {
  let service: ConfirmDeleteService;
  const openSpy = vi.fn();

  function closeWith(result: unknown) {
    openSpy.mockReturnValue({ afterClosed: of({ result }) });
  }

  beforeEach(() => {
    vi.clearAllMocks();
    TestBed.configureTestingModule({
      providers: [{ provide: SbbDialogService, useValue: { open: openSpy } }],
    });
    service = TestBed.inject(ConfirmDeleteService);
  });

  it('should open the confirm dialog with the number of entries', async () => {
    closeWith('confirm');

    await service.confirm(3);

    expect(openSpy).toHaveBeenCalledWith(
      ConfirmDeleteDialog,
      expect.objectContaining({ data: { count: 3 } }),
    );
  });

  it('should use a translucent backdrop', async () => {
    closeWith('confirm');
    await service.confirm(1);
    const dialog = { backdrop: 'opaque' };
    const config = openSpy.mock.calls[0][1] as {
      setupContainer: (dialog: { backdrop: string }) => void;
    };

    config.setupContainer(dialog);

    expect(dialog.backdrop).toBe('translucent');
  });

  it('should resolve true when confirmed', async () => {
    closeWith('confirm');

    expect(await service.confirm(1)).toBe(true);
  });

  it('should resolve false when cancelled or dismissed', async () => {
    closeWith(null);

    expect(await service.confirm(1)).toBe(false);
  });
});
