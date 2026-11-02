import { inject, Service } from '@angular/core';
import { SbbDialogService } from '@sbb-esta/lyne-angular/dialog';
import { firstValueFrom } from 'rxjs';
import {
  ConfirmDeleteDialog,
  ConfirmDeleteDialogData,
  ConfirmDeleteDialogResult,
} from '~shared/components/confirm-delete-dialog/confirm-delete-dialog';

@Service()
export class ConfirmDeleteService {
  private readonly dialogService = inject(SbbDialogService);

  /**
   * Ask the user to confirm deleting entries.
   * @param count Number of entries that will be deleted
   * @returns true if the user confirmed, false if the dialog was cancelled or dismissed
   */
  async confirm(count: number): Promise<boolean> {
    const dialogRef = this.dialogService.open<ConfirmDeleteDialog, ConfirmDeleteDialogResult>(
      ConfirmDeleteDialog,
      {
        data: { count } satisfies ConfirmDeleteDialogData,
        // Keep an underlying edit dialog visible behind the confirmation.
        setupContainer: (dialog) => (dialog.backdrop = 'translucent'),
      },
    );
    const { result } = await firstValueFrom(dialogRef.afterClosed);
    return result === 'confirm';
  }
}
