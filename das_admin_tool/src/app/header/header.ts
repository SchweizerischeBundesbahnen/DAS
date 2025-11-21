import {Component} from '@angular/core';
import {SbbHeader, SbbHeaderButton, SbbHeaderEnvironment} from "@sbb-esta/lyne-angular/header";
import {SbbMenu, SbbMenuButton} from "@sbb-esta/lyne-angular/menu";
import {environment} from '../../environments/environment';
import packageJson from '../../../package.json';

@Component({
  selector: 'app-header',
  imports: [
    SbbHeader,
    SbbHeaderButton,
    SbbHeaderEnvironment,
    SbbMenu,
    SbbMenuButton
  ],
  templateUrl: './header.html',
  styleUrl: './header.css',
})
export class Header {
  protected stage = environment.stage;
  protected version = packageJson.version;
}
