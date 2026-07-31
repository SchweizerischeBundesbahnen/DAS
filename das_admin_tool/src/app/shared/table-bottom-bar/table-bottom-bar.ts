import { Component, input, output, viewChild } from '@angular/core';
import { SbbSecondaryButton, SbbTransparentButton } from '@sbb-esta/lyne-angular/button';
import { SbbCompactPaginator } from '@sbb-esta/lyne-angular/paginator';

@Component({
  selector: 'app-table-bottom-bar',
  imports: [SbbCompactPaginator, SbbSecondaryButton, SbbTransparentButton],
  templateUrl: './table-bottom-bar.html',
  styleUrl: './table-bottom-bar.css',
})
export class TableBottomBar {
  readonly showDelete = input(true);
  readonly deleteDisabled = input(true);
  readonly deleting = input(false);
  readonly selectedCount = input(0);
  readonly addLabel = input($localize`:@@button_create_entry:Neuen Eintrag erfassen`);
  readonly addClicked = output<void>();
  readonly deleteClicked = output<void>();
  readonly paginator = viewChild.required<SbbCompactPaginator>(SbbCompactPaginator);
  protected readonly PAGE_SIZE = 20;
}
