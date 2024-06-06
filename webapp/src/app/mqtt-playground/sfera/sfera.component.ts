import { Component } from '@angular/core';
import { FormControl, FormsModule, ReactiveFormsModule } from "@angular/forms";
import { SbbButton } from "@sbb-esta/angular/button";
import { SbbFormField, SbbLabel } from "@sbb-esta/angular/form-field";
import { SbbInput } from "@sbb-esta/angular/input";
import { MqService } from "../../mq.service";

@Component({
  selector: 'app-sfera',
  standalone: true,
  imports: [
    FormsModule,
    SbbButton,
    SbbFormField,
    SbbInput,
    SbbLabel,
    ReactiveFormsModule
  ],
  templateUrl: './sfera.component.html',
  styleUrl: './sfera.component.scss'
})
export class SferaComponent {

  companyControl = new FormControl('');
  trainControl = new FormControl('');
  clientIdControl = new FormControl('');


  constructor(public mqService: MqService) {
    this.clientIdControl.setValue(crypto.randomUUID());

  }

  start() {
    this.mqService.subscribe('90940/2/G2B/' + this.companyControl.value + '/' + this.trainControl.value + '/' + this.clientIdControl.value)
      .subscribe(value => console.log('got g2b', value.payload.toString()))
    this.mqService.publish('90940/2/B2G/' + this.companyControl.value + '/' + this.trainControl.value + '/' + this.clientIdControl.value, this.handshakeRequest())
  }

  handshakeRequest() {
    return `
      <SFERA_B2G_RequestMessage>
        <MessageHeader SFERA_version="2.01" message_ID="${crypto.randomUUID()}"
                       timestamp="${new Date().toISOString()}" sourceDevice="DAS">
            <Sender>${this.companyControl.value}</Sender>
            <Recipient>0085</Recipient>
        </MessageHeader>
        <HandshakeRequest>
            <DAS_OperatingModesSupported DAS_drivingMode="Read-Only" DAS_architecture="GroundAdviceCalculation" DAS_connectivity="Connected"/>
        </HandshakeRequest>
      </SFERA_B2G_RequestMessage>
    `
  }
}
