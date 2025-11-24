import {Component} from '@angular/core';
import {SbbTitle} from '@sbb-esta/lyne-angular/title';
import {DatePipe} from '@angular/common';


@Component({
  selector: 'app-home',
  imports: [
    SbbTitle,
    DatePipe
  ],
  templateUrl: './home.html',
  styleUrl: './home.css',
})
export class Home {
  protected today = new Date();
}
