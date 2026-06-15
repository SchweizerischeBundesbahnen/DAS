import { computed, Injectable } from '@angular/core';
import { httpResource } from '@angular/common/http';
import { ApiResponse } from '../../../../shared/api-response';
import { environment } from '../../../../../environments/environment';

export type LocationApiResponse = ApiResponse<Location>;

export interface Location {
  locationReference: string;
  primaryLocationName: string;
  locationAbbreviation?: string;
  validFrom?: Date;
}

@Injectable({
  providedIn: 'root',
})
export class LocationService {
  private readonly url = `${environment.backendUrl}/v1/locations`;

  private readonly locationsResource = httpResource<LocationApiResponse>(() => this.url);
  private readonly locations = computed(() => this.locationsResource.value()?.data ?? []);

  public getLocation(reference: string) {
    return this.locations().find(location => location.locationReference === reference);
  }

  public filterLocations(query: string, excludedReferences: string[] = []) {
    const q = query.trim().toLowerCase();
    if (q.length < 2) {
      return []
    }
    const includesQuery = this.locations().filter(loc =>
      ((loc.primaryLocationName?.toLowerCase().includes(q)) ||
        (loc.locationAbbreviation?.toLowerCase().includes(q))) &&
      !excludedReferences.includes(loc.locationReference)
    );
    return this.sortByRelevance(includesQuery, q);
  }

  private sortByRelevance(includesQuery: Location[], q: string) {
    return includesQuery.sort((a, b) => {
      const aName = a.primaryLocationName?.toLowerCase() ?? '';
      const bName = b.primaryLocationName?.toLowerCase() ?? '';
      const aAbbr = a.locationAbbreviation?.toLowerCase() ?? '';
      const bAbbr = b.locationAbbreviation?.toLowerCase() ?? '';

      const aRank = Math.min(this.rank(q, aName), this.rank(q, aAbbr));
      const bRank = Math.min(this.rank(q, bName), this.rank(q, bAbbr));
      if (aRank !== bRank) return aRank - bRank;
      return aName.localeCompare(bName);
    });
  }

  private rank(query: string, str: string): number {
    if (str === query) return 0; // exact
    if (str.startsWith(query)) return 1; // prefix
    if (str.includes(query)) return 2; // substring
    return 3;
  }
}
