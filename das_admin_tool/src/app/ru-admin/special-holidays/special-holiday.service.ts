import {inject, Injectable} from '@angular/core';
import {ToastService} from '../../shared/toast-service';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {firstValueFrom, Observable} from 'rxjs';
import {RuAdminApi, SpecialHoliday} from '../ru-admin-api';
import {
  SpecialHolidayDialog,
  SpecialHolidayDialogEditResult
} from './special-holiday-dialog/special-holiday-dialog.component';
import {RecentCompaniesStore} from '../../shared/recent-companies.store';

@Injectable({
  providedIn: 'root',
})
export class SpecialHolidayService {
  private readonly ruAdminApi = inject(RuAdminApi);
  readonly specialHolidaysResource = this.ruAdminApi.specialHolidays;
  private readonly dialogService = inject(SbbDialogService);
  private readonly toastService = inject(ToastService);
  private readonly recentCompaniesStore = inject(RecentCompaniesStore);

  async edit(specialHoliday: SpecialHoliday): Promise<void> {
    const event = await firstValueFrom(this.dialogService.open<SpecialHolidayDialog, SpecialHolidayDialogEditResult>(SpecialHolidayDialog, {data: specialHoliday}).afterClosed);
    if (event.result === 'delete') {
      await this.runMutation(
        this.ruAdminApi.deleteSpecialHoliday(specialHoliday.id!),
        $localize`:@@special_holidays_toast_delete_success:Der Feiertag wurde erfolgreich geloescht.`,
      );
    } else if (event.result && specialHoliday.id) {
      this.recentCompaniesStore.save(event.result.companies);
      await this.runMutation(
        this.ruAdminApi.putSpecialHoliday(specialHoliday.id, event.result),
        $localize`:@@special_holidays_toast_edit_success:Der Feiertag wurde erfolgreich gespeichert.`,
      );
    }
  }

  async add(): Promise<void> {
    const event = await firstValueFrom(this.dialogService.open<SpecialHolidayDialog, SpecialHoliday>(SpecialHolidayDialog).afterClosed);
    if (event.result) {
      this.recentCompaniesStore.save(event.result.companies);
      await this.runMutation(
        this.ruAdminApi.postSpecialHoliday(event.result),
        $localize`:@@special_holidays_toast_create_success:Der Feiertag wurde erfolgreich erstellt.`,
      );
    }
  }

  async deleteAll(holidays: SpecialHoliday[]): Promise<void> {
    await this.runMutation(
      this.ruAdminApi.deleteAllSpecialHolidays(holidays.map((holiday) => holiday.id!)),
      $localize`:@@special_holidays_toast_delete_all_success:Die Feiertage wurden erfolgreich geloescht.`,
    );
  }

  private reloadSpecialHolidays() {
    this.ruAdminApi.specialHolidays.reload();
  }

  private async runMutation(request: Observable<unknown>, successMessage: string): Promise<void> {
    await firstValueFrom(request)
      .then(() => {
        this.toastService.success(successMessage);
        this.reloadSpecialHolidays();
      })
      .catch(() => this.handleApiError());
  }

  private handleApiError(): void {
    this.toastService.error($localize`:@@special_holidays_toast_error:Beim Speichern ist ein Fehler aufgetreten.`);
  }
}
