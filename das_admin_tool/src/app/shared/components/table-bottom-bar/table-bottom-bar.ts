import { Component, viewChild } from '@angular/core';
import { SbbCompactPaginator } from '@sbb-esta/lyne-angular/paginator';

@Component({
  selector: 'app-table-bottom-bar',
  imports: [SbbCompactPaginator],
  templateUrl: './table-bottom-bar.html',
  styleUrl: './table-bottom-bar.css',
})
export class TableBottomBar {
  readonly paginator = viewChild.required<SbbCompactPaginator>(SbbCompactPaginator);

  protected readonly PAGE_SIZE = 20;
}
