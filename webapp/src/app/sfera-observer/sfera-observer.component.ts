import { Component, OnDestroy } from '@angular/core';
import { FormControl, ReactiveFormsModule } from "@angular/forms";
import { SbbFormFieldModule } from "@sbb-esta/angular/form-field";
import { SbbInputModule } from "@sbb-esta/angular/input";
import { MqService } from "../mq.service";
import { SbbButtonModule } from "@sbb-esta/angular/button";
import { SimpleXmlComponent } from "../simple-xml/simple-xml.component";
import { AuthService } from "../auth.service";
import { firstValueFrom, map, Subscription } from "rxjs";
import { CommonModule } from "@angular/common";
import { MqttConnectionState } from "ngx-mqtt";
import { OidcSecurityService } from "angular-auth-oidc-client";
import { SbbSelectModule } from "@sbb-esta/angular/select";

@Component({
  selector: 'app-sfera-observer',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    SbbFormFieldModule,
    SbbInputModule,
    SbbButtonModule,
    SimpleXmlComponent,
    SbbSelectModule
  ],
  templateUrl: './sfera-observer.component.html',
  styleUrl: './sfera-observer.component.scss',
})
export class SferaObserverComponent implements OnDestroy {
  environments = ['', 'dev', 'e2e'];
  environmentControl = new FormControl('', {nonNullable: true});
  companyControl = new FormControl('1088', {nonNullable: true});
  trainControl = new FormControl('9232', {nonNullable: true});
  dateControl = new FormControl(new Date().toISOString().split('T')[0], {nonNullable: true});
  clientIdControl = new FormControl('', {nonNullable: true});
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
    const env = this.environmentControl.value !== '' ? this.environmentControl.value + '/' : '';
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
