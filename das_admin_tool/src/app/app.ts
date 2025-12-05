import {Component} from '@angular/core';
import {RouterOutlet} from '@angular/router';
import {Header} from './header/header';
import {IconSidebar} from './icon-sidebar/icon-sidebar';

@Component({
  selector: 'app-root',
  imports: [RouterOutlet, Header, IconSidebar],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
}
