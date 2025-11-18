import {Component} from '@angular/core';
import {RouterOutlet} from '@angular/router';
import {SbbContainer} from '@sbb-esta/lyne-angular/container/container';
import {Header} from './header/header';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, SbbContainer, Header],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected title = 'das_admintool';
}
