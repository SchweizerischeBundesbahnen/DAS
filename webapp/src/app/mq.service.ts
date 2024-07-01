import { Injectable, OnDestroy } from '@angular/core';
import { IMqttServiceOptions, MqttService } from "ngx-mqtt";
import { AuthService } from "./auth.service";
import { firstValueFrom } from "rxjs";
import { environment } from "../environment/environment";

@Injectable({
  providedIn: 'root'
})
export class MqService implements OnDestroy {

  state = this.mqttService.state;

  connectionConfig: IMqttServiceOptions = {
    hostname: 'das-poc.messaging.solace.cloud',
    port: 8443,
    clean: true, // Retain session
    connectTimeout: 4000, // Timeout period
    reconnectPeriod: 4000, // Reconnect period
    clientId: 'webapp-' + crypto.randomUUID(),
    protocol: 'wss',
  }

  constructor(private authService: AuthService, private mqttService: MqttService) {
  }

  ngOnDestroy(): void {
    this.mqttService.disconnect();
  }

  async connect(ru: string, train: string, role: string) {
    const exchangeToken = await firstValueFrom(this.authService.exchange(ru, train, role));
    this.connectionConfig = {
      username: this.authService.preferredUsername,
      password: this.oauthAccessTokenString(exchangeToken),
      ...this.connectionConfig
    }

    this.mqttService.connect(this.connectionConfig);
    this.mqttService.onConnect.subscribe(() => {
      console.log('Connection succeeded!');
    });
    this.mqttService.onError.subscribe((error) => {
      console.log('Connection failed', error)
    })
  }

  subscribe(topic: string) {
    return this.mqttService.observe(topic);
  }

  publish(topic: string, message: string) {
    this.mqttService.unsafePublish(topic, message);
  }

  // Solace specific oauth access string (used instead of plain "mqttPassword"))
  private oauthAccessTokenString(token: string): string {
    return `OAUTH~${environment.oauthProfile}~${token}`;
  }
}
