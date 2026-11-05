import { Component, inject } from '@angular/core';
import { SbbButtonModule } from '@sbb-esta/lyne-angular/button';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbDialogModule } from '@sbb-esta/lyne-angular/dialog';

export interface ConfirmDeleteDialogData {
  count: number;
}

export type ConfirmDeleteDialogResult = 'confirm';

@Component({
  selector: 'app-confirm-delete-dialog',
  imports: [SbbButtonModule, SbbDialogModule],
  templateUrl: './confirm-delete-dialog.html',
  styleUrl: './confirm-delete-dialog.css',
})
export class ConfirmDeleteDialog {
  protected readonly count = inject<ConfirmDeleteDialogData>(SBB_OVERLAY_DATA).count;
}
