import { Component, CUSTOM_ELEMENTS_SCHEMA, OnDestroy } from '@angular/core';
import { MqSubscriberComponent } from "./mq-subscriber/mq-subscriber.component";
import { MqPublisherComponent } from "./mq-publisher/mq-publisher.component";
import { MqService } from "../mq.service";
import { AsyncPipe } from "@angular/common";
import { MqttConnectionState } from "ngx-mqtt";
import { AuthService } from "../auth.service";
import { firstValueFrom, map } from "rxjs";
import { OidcSecurityService } from "angular-auth-oidc-client";

@Component({
    selector: 'app-mqtt-playground',
    imports: [
        MqSubscriberComponent,
        MqPublisherComponent,
        AsyncPipe,
    ],
    schemas: [CUSTOM_ELEMENTS_SCHEMA],
    templateUrl: './mqtt-playground.component.html',
    styleUrl: './mqtt-playground.component.scss'
})
export class MqttPlaygroundComponent implements OnDestroy {

  constructor(public mqService: MqService, private authService: AuthService, private oidcSecurityService: OidcSecurityService) {
    this.authService.exchange().subscribe(async token => {
      const userName = await firstValueFrom(this.oidcSecurityService.getUserData().pipe(map((data) => data?.preferred_username)));
      this.mqService.connect(userName, token)
    });
  }

  ngOnDestroy(): void {
    this.mqService.disconnect()
  }

  protected readonly MqttConnectionState = MqttConnectionState;
}
