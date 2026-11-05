import { Component, input, output } from '@angular/core';
import { SbbButton, SbbTransparentButton } from '@sbb-esta/lyne-angular/button';
import { SbbTitle } from '@sbb-esta/lyne-angular/title';

@Component({
  selector: 'app-page-header',
  imports: [SbbButton, SbbTransparentButton, SbbTitle],
  templateUrl: './page-header.html',
  styleUrl: './page-header.css',
})
export class PageHeader {
  readonly title = input.required<string>();
  readonly showAdd = input(true);
  readonly selectedCount = input(0);
  readonly deleting = input(false);
  readonly addClicked = output<void>();
  readonly deleteClicked = output<void>();
}
