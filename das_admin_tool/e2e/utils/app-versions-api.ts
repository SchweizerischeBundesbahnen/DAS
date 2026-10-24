import { APIRequestContext, Page, Response } from '@playwright/test';

export interface ApiAppVersion {
  id: number;
  version: string;
}

/**
 * Direct backend access for test data cleanup, bypassing the UI.
 */
export class AppVersionsApi {
  private constructor(
    private readonly request: APIRequestContext,
    private readonly url: string,
    private readonly authorization: string,
  ) {}

  /**
   * Reuses the URL and bearer token of the app's own GET /app-versions call, see CompaniesApi.
   */
  static async fromListResponse(page: Page, response: Response): Promise<AppVersionsApi> {
    const authorization = (await response.request().allHeaders())['authorization'];
    if (!authorization) {
      throw new Error(`No authorization header on ${response.url()}`);
    }
    return new AppVersionsApi(page.request, response.url(), authorization);
  }

  async list(): Promise<ApiAppVersion[]> {
    const response = await this.request.get(this.url, { headers: this.headers() });
    if (!response.ok()) {
      throw new Error(`GET ${this.url} failed with ${response.status()}: ${await response.text()}`);
    }
    return ((await response.json()) as { data: ApiAppVersion[] }).data;
  }

  async delete(id: number): Promise<void> {
    const response = await this.request.delete(`${this.url}/${id}`, { headers: this.headers() });
    // 404: already deleted, e.g. by the test itself
    if (!response.ok() && response.status() !== 404) {
      throw new Error(`DELETE ${this.url}/${id} failed with ${response.status()}`);
    }
  }

  private headers() {
    return { authorization: this.authorization };
  }
}
