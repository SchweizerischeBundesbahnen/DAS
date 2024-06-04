import { Component } from '@angular/core';
import { MqSubscriberComponent } from "./mq-subscriber/mq-subscriber.component";
import { MqPublisherComponent } from "./mq-publisher/mq-publisher.component";

@Component({
  selector: 'app-mqtt-playground',
  standalone: true,
  imports: [
    MqSubscriberComponent,
    MqPublisherComponent
  ],
  templateUrl: './mqtt-playground.component.html',
  styleUrl: './mqtt-playground.component.scss'
})
export class MqttPlaygroundComponent {
}
