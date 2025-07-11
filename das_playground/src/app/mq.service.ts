import { DestroyRef, inject, Injectable } from '@angular/core';
import { MqttService } from "ngx-mqtt";
import { environment } from "../environments/environment";
import { takeUntilDestroyed } from "@angular/core/rxjs-interop";
import { SbbNotificationToast } from "@sbb-esta/angular/notification-toast";

@Injectable({
  providedIn: 'root'
})
export class MqService {
  private mqttService = inject(MqttService);
  private _notification = inject(SbbNotificationToast);


  state = this.mqttService.state;
  private _destroyed = inject(DestroyRef);

  constructor() {
    this.mqttService.onError
      .pipe(takeUntilDestroyed(this._destroyed))
      .subscribe(val => {
        this._notification
          .open(val.message, {
            type: 'error',
          })
        this.mqttService.disconnect();
      });
  }

  async connect(username: string, token: string) {
    this.mqttService.connect({
      username: username,
      password: `OAUTH~${environment.oauthProfile}~${token}`
    });
  }

  observe(topic: string) {
    return this.mqttService.observe(topic);
  }

  publish(topic: string, message: string) {
    this.mqttService.unsafePublish(topic, message);
  }

  disconnect() {
    try {
      this.mqttService.disconnect();
    } catch (e) {
      /* no open connection */
      console.log(e)
    }
  }
}
