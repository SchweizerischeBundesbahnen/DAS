import { Component } from '@angular/core';
import { MqSubscriberComponent } from "./mq-subscriber/mq-subscriber.component";
import { MqPublisherComponent } from "./mq-publisher/mq-publisher.component";
import { MqService } from "../mq.service";
import { SbbIcon } from "@sbb-esta/angular/icon";
import { AsyncPipe } from "@angular/common";
import { MqttConnectionState } from "ngx-mqtt";
import { SferaComponent } from "./sfera/sfera.component";

@Component({
  selector: 'app-mqtt-playground',
  standalone: true,
  imports: [
    MqSubscriberComponent,
    MqPublisherComponent,
    SbbIcon,
    AsyncPipe,
    SferaComponent
  ],
  templateUrl: './mqtt-playground.component.html',
  styleUrl: './mqtt-playground.component.scss'
})
export class MqttPlaygroundComponent {

  constructor(public mqService: MqService) {
  }

  protected readonly MqttConnectionState = MqttConnectionState;
}
