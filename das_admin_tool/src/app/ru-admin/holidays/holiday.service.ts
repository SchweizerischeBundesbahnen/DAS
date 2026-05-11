import {inject, Injectable} from '@angular/core';
import {ToastService} from '../../shared/toast-service';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {firstValueFrom, Observable} from 'rxjs';
import {Holiday, RuAdminApi} from '../ru-admin-api';
import {HolidayDialog, HolidayDialogEditResult} from './holiday-dialog/holiday-dialog';
import {RecentCompaniesStore} from '../../shared/recent-companies.store';

@Injectable({
  providedIn: 'root',
})
export class HolidayService {
  private readonly ruAdminApi = inject(RuAdminApi);
  readonly holidaysResource = this.ruAdminApi.holidays;
  private readonly dialogService = inject(SbbDialogService);
  private readonly toastService = inject(ToastService);
  private readonly recentCompaniesStore = inject(RecentCompaniesStore);

  async edit(holiday: Holiday): Promise<void> {
    const event = await firstValueFrom(this.dialogService.open<HolidayDialog, HolidayDialogEditResult>(HolidayDialog, {data: holiday}).afterClosed);
    if (event.result === 'delete') {
      await this.runMutation(
        this.ruAdminApi.deleteHoliday(holiday.id!),
        $localize`:@@holidays_toast_delete_success:Der Feiertag wurde erfolgreich geloescht.`,
      );
    } else if (event.result && holiday.id) {
      this.recentCompaniesStore.save(event.result.companies);
      await this.runMutation(
        this.ruAdminApi.putHoliday(holiday.id, event.result),
        $localize`:@@holidays_toast_edit_success:Der Feiertag wurde erfolgreich gespeichert.`,
      );
    }
  }

  async add(): Promise<void> {
    const event = await firstValueFrom(this.dialogService.open<HolidayDialog, Holiday>(HolidayDialog).afterClosed);
    if (event.result) {
      this.recentCompaniesStore.save(event.result.companies);
      await this.runMutation(
        this.ruAdminApi.postHoliday(event.result),
        $localize`:@@holidays_toast_create_success:Der Feiertag wurde erfolgreich erstellt.`,
      );
    }
  }

  async deleteAll(holidays: Holiday[]): Promise<void> {
    await this.runMutation(
      this.ruAdminApi.deleteAllHolidays(holidays.map((holiday) => holiday.id!)),
      $localize`:@@holidays_toast_delete_all_success:Die Feiertage wurden erfolgreich geloescht.`,
    );
  }

  private reloadHolidays() {
    this.ruAdminApi.holidays.reload();
  }

  private async runMutation(request: Observable<unknown>, successMessage: string): Promise<void> {
    await firstValueFrom(request)
      .then(() => {
        this.toastService.success(successMessage);
        this.reloadHolidays();
      })
      .catch(() => this.handleApiError());
  }

  private handleApiError(): void {
    this.toastService.error($localize`:@@holidays_toast_error:Beim Speichern ist ein Fehler aufgetreten.`);
  }
}
