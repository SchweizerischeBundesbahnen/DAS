import { Component } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { SbbTabNavBar } from '@sbb-esta/lyne-angular/tabs';
import { SbbTitle } from '@sbb-esta/lyne-angular/title';

@Component({
  selector: 'app-das-admin',
  imports: [SbbTitle, SbbTabNavBar, RouterOutlet, RouterLink, RouterLinkActive],
  templateUrl: './das-admin.html',
  styleUrl: './das-admin.css',
})
export class DasAdmin {}
