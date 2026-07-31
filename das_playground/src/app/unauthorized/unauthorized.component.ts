import { Component, ChangeDetectionStrategy } from '@angular/core';
import { SbbNotificationModule } from '@sbb-esta/angular/notification';

@Component({
  selector: 'app-unauthorized',
  imports: [SbbNotificationModule],
  templateUrl: './unauthorized.component.html',
  changeDetection: ChangeDetectionStrategy.Eager,
  styleUrl: './unauthorized.component.scss',
})
export class UnauthorizedComponent {}
