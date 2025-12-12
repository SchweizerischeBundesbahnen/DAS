import {inject, Injectable} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {environment} from "../../environments/environment";

export interface Formation {
  companyCode: string;
  operationalDay: string;
  operationalTrainNumber: string;
}

@Injectable({
  providedIn: 'root'
})
export class FormationsService {
  private httpClient = inject(HttpClient);


  private url = `${environment.backendUrl}/actuator/formations`;

  initialFormation(formation: Formation) {
    return this.httpClient.post<void>(this.url, {
      state: 'INITIAL',
      ...formation
    })
  }

  updateFormation(formation: Formation) {
    return this.httpClient.post<void>(this.url, {
      state: 'UPDATED',
      ...formation
    })
  }
}
