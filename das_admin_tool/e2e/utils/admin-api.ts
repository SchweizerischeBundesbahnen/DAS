import { APIRequestContext, Page, Response } from '@playwright/test';

export interface ApiCompany {
  id: number;
  code: string;
  shortName: string;
}

export interface ApiAppVersion {
  id: number;
  version: string;
}

/**
 * Direct backend access for test data setup and cleanup of one admin resource, bypassing the UI.
 */
export class AdminApi<T extends { id: number }> {
  private constructor(
    private readonly request: APIRequestContext,
    private readonly url: string,
    private readonly authorization: string,
  ) {}

  /**
   * The test has no token of its own (the app logs in via Entra ID and keeps the token in the
   * browser session), so reuse the URL and bearer token of the app's own list call.
   */
  static async fromListResponse<T extends { id: number }>(
    page: Page,
    response: Response,
  ): Promise<AdminApi<T>> {
    const authorization = (await response.request().allHeaders())['authorization'];
    if (!authorization) {
      throw new Error(`No authorization header on ${response.url()}`);
    }
    return new AdminApi<T>(page.request, response.url(), authorization);
  }

  async list(): Promise<T[]> {
    const response = await this.request.get(this.url, { headers: this.headers() });
    if (!response.ok()) {
      throw new Error(`GET ${this.url} failed with ${response.status()}: ${await response.text()}`);
    }
    return ((await response.json()) as { data: T[] }).data;
  }

  async delete(id: number): Promise<void> {
    const response = await this.request.delete(`${this.url}/${id}`, { headers: this.headers() });
    // 404: already deleted, e.g. by the test itself or a parallel run's cleanup
    if (!response.ok() && response.status() !== 404) {
      throw new Error(`DELETE ${this.url}/${id} failed with ${response.status()}`);
    }
  }

  private headers() {
    return { authorization: this.authorization };
  }
}
