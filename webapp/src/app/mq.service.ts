import { Injectable } from '@angular/core';
import { IMqttServiceOptions, MqttService } from "ngx-mqtt";
import { AuthService } from "./auth.service";

@Injectable({
  providedIn: 'root'
})
export class MqService {

  connectionConfig: IMqttServiceOptions = {
    hostname: 'das-poc.messaging.solace.cloud',
    port: 8443,
    // path: '/AbbaAbbbAbbc',
    clean: true, // Retain session
    connectTimeout: 4000, // Timeout period
    reconnectPeriod: 4000, // Reconnect period
    // Authentication information
    clientId: 'webapp',
    username: this.authService.preferredUsername,
    // OAUTH~${environment.oauthProfile}~${this.getAccessToken}
    password: this.authService.oauthAccessTokenString,
    protocol: 'wss',
  }

  constructor(private authService: AuthService, private mqttService: MqttService) {
    this.connect();
  }

  connect() {
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

}
