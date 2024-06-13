import { Component } from '@angular/core';
import { FormControl, FormsModule, ReactiveFormsModule } from "@angular/forms";
import { SbbButtonModule } from "@sbb-esta/angular/button";
import { SbbFormFieldModule } from "@sbb-esta/angular/form-field";
import { SbbInputModule } from "@sbb-esta/angular/input";
import { MqService } from "../../mq.service";

@Component({
  selector: 'app-mq-publisher',
  standalone: true,
  imports: [
    FormsModule,
    ReactiveFormsModule,
    SbbFormFieldModule,
    SbbInputModule,
    SbbButtonModule,
  ],
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
