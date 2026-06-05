import { inject } from '@angular/core';
import { ToastService } from '../shared/toast-service';
import { RecentCompaniesStore } from '../shared/recent-companies.store';
import { firstValueFrom, Observable } from 'rxjs';

export abstract class BaseDialogService {
  protected readonly toastService = inject(ToastService);
  protected readonly recentCompaniesStore = inject(RecentCompaniesStore);

  protected abstract reload(): void;

  /**
   * Execute a mutation (create/update/delete) with automatic error handling and companies tracking.
   * @param request The observable mutation request
   * @param successMessage The message to show on success
   * @param companies Optional list of companies to save to recent store
   */
  protected async runMutation(
    request: Observable<unknown>,
    successMessage: string,
    companies?: string[]
  ): Promise<void> {
    await firstValueFrom(request)
      .then(() => {
        if (companies && companies.length > 0) {
          this.recentCompaniesStore.save(companies);
        }
        this.toastService.success(successMessage);
        this.reload();
      })
      .catch(e => this.handleApiError(e));
  }

  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  protected handleApiError(_: unknown) {
    this.toastService.error($localize`:@@dialog_service_error:Beim Speichern ist ein Fehler aufgetreten.`)
  }
}

