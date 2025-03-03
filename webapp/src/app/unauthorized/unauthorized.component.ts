import { Component } from '@angular/core';
import { SbbNotification } from "@sbb-esta/lyne-angular/notification";


@Component({
  selector: 'app-unauthorized',
  standalone: true,
  imports: [
    SbbNotification
  ],
  templateUrl: './unauthorized.component.html',
  styleUrl: './unauthorized.component.scss'
})
export class UnauthorizedComponent {
}
