import { Injectable, inject } from '@angular/core';
import { HttpClient } from "@angular/common/http";
import { Observable } from "rxjs";
import { environment } from "../../environments/environment";

export interface Session {
  companyCode: string;
  date: string;
  clientId: string;
  operationalNumber: string;
  timestamp?: Date;
}

@Injectable({
  providedIn: 'root'
})
export class SessionsService {
  private httpClient = inject(HttpClient);


  private url = `${environment.backendUrl}/actuator/sessions`;


  getSessions(): Observable<Session[]> {
    return this.httpClient.get<Session[]>(this.url);
  }

  nextLocation(session: Session) {
    return this.httpClient.post<void>(this.url, session)
  }
}
