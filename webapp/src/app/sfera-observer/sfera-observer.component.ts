import { Component, OnDestroy } from '@angular/core';
import { FormControl, ReactiveFormsModule } from "@angular/forms";
import { MqService } from "../mq.service";
import { SimpleXmlComponent } from "../simple-xml/simple-xml.component";
import { AuthService } from "../auth.service";
import { firstValueFrom, map, Subscription } from "rxjs";
import { CommonModule } from "@angular/common";
import { MqttConnectionState } from "ngx-mqtt";
import { OidcSecurityService } from "angular-auth-oidc-client";
import { SbbButtonDirective } from "@sbb-esta/lyne-angular/button/button";
import { SbbCheckboxDirective } from "@sbb-esta/lyne-angular/checkbox/checkbox";
import { SbbFormFieldDirective } from "@sbb-esta/lyne-angular/form-field/form-field";

@Component({
    selector: 'app-sfera-observer',
    imports: [
        CommonModule,
        ReactiveFormsModule,
        SimpleXmlComponent,
      SbbButtonDirective,
      SbbCheckboxDirective,
      SbbFormFieldDirective
    ],
    templateUrl: './sfera-observer.component.html',
    styleUrl: './sfera-observer.component.scss'
})
export class SferaObserverComponent implements OnDestroy {
  companyControl = new FormControl('1088', {nonNullable: true});
  trainControl = new FormControl('9232', {nonNullable: true});
  dateControl = new FormControl(new Date().toISOString().split('T')[0], {nonNullable: true});
  clientIdControl = new FormControl('', {nonNullable: true});
  environmentControl = new FormControl(false, {nonNullable: true});
  g2bTopic?: string;
  b2gTopic?: string;
  messages: { message: string, topic: string }[] = [];

  g2bSubscription?: Subscription;
  b2gSubscription?: Subscription;

  protected readonly MqttConnectionState = MqttConnectionState;

  constructor(private oidcSecurityService: OidcSecurityService,
              private authService: AuthService,
              protected mqService: MqService) {
  }

  async observe() {
    const env = this.environmentControl.value ? 'local/' : '';
    const trainOperation = this.dateControl.value + '_' + this.trainControl.value;
    this.g2bTopic = env + '90940/2/G2B/' + this.companyControl.value + '/' + trainOperation + '/' + this.clientIdControl.value;
    this.b2gTopic = env + '90940/2/B2G/' + this.companyControl.value + '/' + trainOperation + '/' + this.clientIdControl.value
    const exchangeToken = await firstValueFrom(this.authService.exchange(this.companyControl.value, trainOperation, 'read-only'));
    const username = await firstValueFrom(this.oidcSecurityService.getUserData().pipe(map((data) => data?.preferred_username)));
    await this.mqService.connect(username, exchangeToken);

    this.g2bSubscription = this.mqService.observe(this.g2bTopic)
      .subscribe(value => {
        this.messages.push({message: value.payload.toString(), topic: 'g2b'})
      })
    this.b2gSubscription = this.mqService.observe(this.b2gTopic).subscribe(value => {
      this.messages.push({message: value.payload.toString(), topic: 'b2g'})
    })
  }

  disconnect() {
    this.messages = [];
    this.g2bSubscription?.unsubscribe();
    this.b2gSubscription?.unsubscribe();
    this.mqService.disconnect();
  }

  ngOnDestroy() {
    this.disconnect();
  }
}
