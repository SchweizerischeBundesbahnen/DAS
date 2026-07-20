import { Component } from '@angular/core';
import { SbbTitle } from '@sbb-esta/lyne-angular/title';
import { SbbTabNavBar } from '@sbb-esta/lyne-angular/tabs';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-das-admin',
  imports: [SbbTitle, SbbTabNavBar, RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './das-admin.html',
  styleUrl: './das-admin.css',
})
export class DasAdmin {}
