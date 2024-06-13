import { Component } from '@angular/core';
import { MqttPlaygroundComponent } from "./mqtt-playground/mqtt-playground.component";

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [MqttPlaygroundComponent],
  templateUrl: './app.component.html',
  styleUrl: './app.component.scss',
})
export class AppComponent {
  title = 'webapp';
}
