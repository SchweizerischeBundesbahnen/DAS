import { inject, Injectable } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { BaseDialogService } from '../base-dialog.service';
import { RuAdminApi, SpecialHoliday } from '../ru-admin-api';
import {
  SpecialHolidayDialog,
  SpecialHolidayDialogEditResult,
} from './special-holiday-dialog/special-holiday-dialog.component';

@Injectable({ providedIn: 'root' })
export class SpecialHolidayService extends BaseDialogService {
  private readonly ruAdminApi = inject(RuAdminApi);
  readonly specialHolidaysResource = this.ruAdminApi.specialHolidays;

  async edit(specialHoliday: SpecialHoliday): Promise<void> {
    const event = await firstValueFrom(
      this.dialogService.open<SpecialHolidayDialog, SpecialHolidayDialogEditResult>(
        SpecialHolidayDialog,
        { data: specialHoliday },
      ).afterClosed,
    );
    if (event.result === 'delete') {
      await this.runMutation(
        this.ruAdminApi.deleteAllSpecialHolidays([specialHoliday.id!]),
        $localize`:@@toast_delete_success:Der Eintrag wurde erfolgreich gelöscht.`,
      );
    } else if (event.result && specialHoliday.id) {
      await this.runMutation(
        this.ruAdminApi.putSpecialHoliday(specialHoliday.id, event.result),
        $localize`:@@special_holidays_toast_edit_success:Der Feiertag wurde erfolgreich gespeichert.`,
        event.result.companies,
      );
    }
  }

  async add(): Promise<void> {
    const event = await firstValueFrom(
      this.dialogService.open<SpecialHolidayDialog, SpecialHoliday>(SpecialHolidayDialog)
        .afterClosed,
    );
    if (event.result) {
      await this.runMutation(
        this.ruAdminApi.postSpecialHoliday(event.result),
        $localize`:@@special_holidays_toast_create_success:Der Feiertag wurde erfolgreich erstellt.`,
        event.result.companies,
      );
    }
  }

  async deleteAll(holidays: SpecialHoliday[]): Promise<void> {
    await this.runMutation(
      this.ruAdminApi.deleteAllSpecialHolidays(holidays.map((holiday) => holiday.id!)),
      $localize`:@@toast_delete_all_success:Die Einträge wurden erfolgreich gelöscht.`,
    );
  }

  protected override reload(): void {
    this.ruAdminApi.specialHolidays.reload();
  }
}
