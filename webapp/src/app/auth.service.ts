import { Injectable } from '@angular/core';
import { Observable } from "rxjs";
import { environment } from "../environment/environment";
import { HttpClient, HttpParams } from "@angular/common/http";

export interface Tenant {
  name: string;
  jwkSetUri: string;
  issuerUri: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {

  constructor(
    private httpClient: HttpClient,
  ) {

  }

  exchange(ru: string = '', train: string = '', role: string = ''): Observable<string> {
    return this.httpClient.get(`${environment.backendUrl}/customClaim/requestToken`, {
      params: new HttpParams().set('ru', ru).set('train', train).set('role', role),
      responseType: 'text',
    })
  }
}
