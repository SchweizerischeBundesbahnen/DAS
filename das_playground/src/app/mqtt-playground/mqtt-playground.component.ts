import { Component, OnDestroy } from '@angular/core';
import { MqSubscriberComponent } from "./mq-subscriber/mq-subscriber.component";
import { MqPublisherComponent } from "./mq-publisher/mq-publisher.component";
import { MqService } from "../mq.service";
import { SbbIcon } from "@sbb-esta/angular/icon";
import { AsyncPipe } from "@angular/common";
import { MqttConnectionState } from "ngx-mqtt";
import { firstValueFrom, map } from "rxjs";
import { OidcSecurityService } from "angular-auth-oidc-client";

@Component({
  selector: 'app-mqtt-playground',
  imports: [
    MqSubscriberComponent,
    MqPublisherComponent,
    SbbIcon,
    AsyncPipe,
  ],
  templateUrl: './mqtt-playground.component.html',
  styleUrl: './mqtt-playground.component.scss'
})
export class MqttPlaygroundComponent implements OnDestroy {

  protected readonly MqttConnectionState = MqttConnectionState;

  constructor(public mqService: MqService, private oidcSecurityService: OidcSecurityService) {
    this.oidcSecurityService.getAccessToken().subscribe(async token => {
      const userName = await firstValueFrom(this.oidcSecurityService.getUserData().pipe(map((data) => data?.preferred_username)));
      this.mqService.connect(userName, token)
    });
  }

  ngOnDestroy(): void {
    this.mqService.disconnect()
  }
}
