import { Component, inject } from '@angular/core';
import { FormControl, FormsModule, ReactiveFormsModule } from "@angular/forms";
import { SbbButtonModule } from "@sbb-esta/angular/button";
import { SbbFormFieldModule } from "@sbb-esta/angular/form-field";
import { SbbInputModule } from "@sbb-esta/angular/input";
import { MqService } from "../../mq.service";

@Component({
  selector: 'app-mq-publisher',
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
  private mqService = inject(MqService);

  topicControl = new FormControl('');
  messageControl = new FormControl('');

  publish() {
    this.mqService.publish(this.topicControl.value!, this.messageControl.value!);
  }
}
