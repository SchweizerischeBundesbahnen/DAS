import {Injectable} from '@angular/core';
import {httpResource} from '@angular/common/http';
import {ApiResponse} from './api-response';
import {environment} from '../../../environments/environment';

export type LocationApiResponse = ApiResponse<Location[]>;

export interface Location {
  locationReference: string;
  primaryLocationName: string;
  locationAbbreviation?: string;
  validFrom?: Date;
}

@Injectable({
  providedIn: 'root',
})
export class LocationsApi {
  private readonly url = `${environment.backendUrl}/v1/locations`;

  locations = httpResource<LocationApiResponse>(() => this.url);
}
