import { Component } from '@angular/core';
import { SbbFormFieldModule } from "@sbb-esta/angular/form-field";
import { SbbButtonModule } from "@sbb-esta/angular/button";
import { MqService } from "../../mq.service";
import { Subscription } from "rxjs";
import { IMqttMessage } from "ngx-mqtt";
import { FormControl, FormsModule, ReactiveFormsModule } from "@angular/forms";
import { SbbInputModule } from "@sbb-esta/angular/input";
import { AsyncPipe, JsonPipe } from "@angular/common";

@Component({
  selector: 'app-mq-subscriber',
  standalone: true,
  imports: [
    FormsModule,
    ReactiveFormsModule,
    SbbButtonModule,
    SbbFormFieldModule,
    SbbInputModule,
    AsyncPipe,
    JsonPipe
  ],
  templateUrl: './mq-subscriber.component.html',
  styleUrl: './mq-subscriber.component.scss'
})
export class MqSubscriberComponent {
  subscription?: Subscription;
  topic?: string;
  messages: IMqttMessage[] = [];
  topicControl = new FormControl('');

  constructor(private mqService: MqService) {
  }

  subscribe() {
    this.topic = this.topicControl.value!;
    this.messages = [];
    this.subscription?.unsubscribe();
    this.subscription = this.mqService.subscribe(this.topicControl.value!).subscribe(message => this.messages.push(message))
  }
}
