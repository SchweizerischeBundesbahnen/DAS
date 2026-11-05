import { Component, inject, input, output } from '@angular/core';
import { SbbButton, SbbTransparentButton } from '@sbb-esta/lyne-angular/button';
import { SbbTitle } from '@sbb-esta/lyne-angular/title';
import { ConfirmDeleteService } from '~shared/services/confirm-delete.service';

@Component({
  selector: 'app-page-header',
  imports: [SbbButton, SbbTransparentButton, SbbTitle],
  templateUrl: './page-header.html',
  styleUrl: './page-header.css',
})
export class PageHeader {
  private readonly confirmDeleteService = inject(ConfirmDeleteService);

  readonly title = input.required<string>();
  readonly showAdd = input(true);
  readonly selectedCount = input(0);
  readonly deleting = input(false);
  readonly addClicked = output<void>();
  readonly deleteClicked = output<void>();

  async delete(): Promise<void> {
    if (await this.confirmDeleteService.confirm(this.selectedCount())) {
      this.deleteClicked.emit();
    }
  }
}
