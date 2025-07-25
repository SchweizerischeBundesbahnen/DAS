import { Component, OnDestroy, inject } from '@angular/core';
import { SbbFormFieldModule } from "@sbb-esta/angular/form-field";
import { SbbButtonModule } from "@sbb-esta/angular/button";
import { MqService } from "../../mq.service";
import { Subscription } from "rxjs";
import { IMqttMessage } from "ngx-mqtt";
import { FormControl, ReactiveFormsModule } from "@angular/forms";
import { SbbInputModule } from "@sbb-esta/angular/input";

@Component({
  selector: 'app-mq-subscriber',
  imports: [
    ReactiveFormsModule,
    SbbButtonModule,
    SbbFormFieldModule,
    SbbInputModule
  ],
  templateUrl: './mq-subscriber.component.html',
  styleUrl: './mq-subscriber.component.scss'
})
export class MqSubscriberComponent implements OnDestroy {
  private mqService = inject(MqService);

  subscriptions: Subscription[] = [];
  messages: IMqttMessage[] = [];
  topicControl = new FormControl('', {nonNullable: true});
  topics: string[] = [];

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
