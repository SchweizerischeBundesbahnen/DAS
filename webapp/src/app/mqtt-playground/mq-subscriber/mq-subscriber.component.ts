import { Component, OnDestroy } from '@angular/core';
import { MqService } from "../../mq.service";
import { Subscription } from "rxjs";
import { IMqttMessage } from "ngx-mqtt";
import { FormControl, ReactiveFormsModule } from "@angular/forms";
import { SbbFormField } from "@sbb-esta/lyne-angular/form-field/form-field";

@Component({
  selector: 'app-mq-subscriber',
  imports: [
    ReactiveFormsModule,
    SbbFormField
  ],
  templateUrl: './mq-subscriber.component.html',
  styleUrl: './mq-subscriber.component.scss'
})
export class MqSubscriberComponent implements OnDestroy {
  subscriptions: Subscription[] = [];
  messages: IMqttMessage[] = [];
  topicControl = new FormControl('', {nonNullable: true});
  topics: string[] = [];

  constructor(private mqService: MqService) {
  }

  ngOnDestroy(): void {
    this.subscriptions.forEach(value => value.unsubscribe());
  }

  subscribe() {
    const topic = this.topicControl.value;
    this.topics.push(topic);
    this.subscriptions.push(this.mqService.observe(this.topicControl.value).subscribe(message => this.messages.push(message)))
    this.topicControl.reset();
  }
}
