import { Component, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { FormControl, FormsModule, ReactiveFormsModule } from "@angular/forms";
import { MqService } from "../../mq.service";

@Component({
    selector: 'app-mq-publisher',
    imports: [
        FormsModule,
        ReactiveFormsModule,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA],
    templateUrl: './mq-publisher.component.html',
    styleUrl: './mq-publisher.component.scss'
})
export class MqPublisherComponent {
  topicControl = new FormControl('');
  messageControl = new FormControl('');

  constructor(private mqService: MqService) {
  }

  publish() {
    this.mqService.publish(this.topicControl.value!, this.messageControl.value!);
  }
}
