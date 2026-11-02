import { inject } from '@angular/core';
import { SbbDialogService } from '@sbb-esta/lyne-angular/dialog';
import { firstValueFrom, Observable } from 'rxjs';
import { RecentCompaniesService } from '~shared/services/recent-companies.service';
import { ToastService } from '~shared/services/toast.service';

export abstract class BaseDialogService {
  protected readonly dialogService = inject(SbbDialogService);
  protected readonly toastService = inject(ToastService);
  protected readonly recentCompaniesService = inject(RecentCompaniesService);

  public abstract edit(edit: unknown): Promise<void>;
  public abstract add(): Promise<void>;
  protected abstract reload(): void;

  /**
   * Execute a mutation (create/update/delete) with automatic error handling and companies tracking.
   * @param request The observable mutation request
   * @param successMessage The message to show on success
   * @param companies Optional list of companies to save to recent store
   * @returns true if the mutation succeeded, false if it failed (error toast already shown)
   */
  protected async runMutation(
    request: Observable<unknown>,
    successMessage: string,
    companies?: string[],
  ): Promise<boolean> {
    return firstValueFrom(request)
      .then(() => {
        if (companies && companies.length > 0) {
          this.recentCompaniesService.save(companies);
        }
        this.toastService.success(successMessage);
        this.reload();
        return true;
      })
      .catch((e) => {
        this.handleApiError(e);
        return false;
      });
  }

  protected handleApiError(_: unknown) {
    this.toastService.error(
      $localize`:@@dialog_service_error:Beim Speichern ist ein Fehler aufgetreten.`,
    );
  }
}
