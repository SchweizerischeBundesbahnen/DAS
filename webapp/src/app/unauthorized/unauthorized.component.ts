import { Component } from '@angular/core';
import { SbbNotificationDirective } from "@sbb-esta/lyne-angular/notification";


@Component({
  selector: 'app-unauthorized',
  standalone: true,
  imports: [
    SbbNotificationDirective
  ],
  templateUrl: './unauthorized.component.html',
  styleUrl: './unauthorized.component.scss'
})
export class UnauthorizedComponent {
}
