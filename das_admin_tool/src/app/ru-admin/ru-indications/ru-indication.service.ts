import {inject, Injectable} from '@angular/core';
import {firstValueFrom} from 'rxjs';
import { RuIndication, RuIndicationTemplate, RuAdminApi } from '../ru-admin-api';
import {RuIndicationDialog} from './ru-indication-dialog/ru-indication-dialog.component';
import { BaseDialogService } from '../base-dialog.service';

export type RuIndicationDialogEditResult = RuIndication | 'delete';

export interface RuIndicationDialogData {
  ruIndication?: RuIndication;
  templates: RuIndicationTemplate[];
}

@Injectable({
  providedIn: 'root',
})
export class RuIndicationService extends BaseDialogService {

  private readonly ruAdminApi = inject(RuAdminApi);
  readonly ruIndicationsResource = this.ruAdminApi.ruIndications;
  private readonly ruIndicationTemplatesResource = this.ruAdminApi.ruIndicationTemplates;

  async edit(ruIndication: RuIndication): Promise<void> {
    const event = await firstValueFrom(this.dialogService.open<RuIndicationDialog, RuIndicationDialogEditResult>(RuIndicationDialog, {
      data: {
        ruIndication: ruIndication,
        templates: this.ruIndicationTemplatesResource.value()?.data
      }
    }).afterClosed);
    if (event.result === 'delete') {
      await this.runMutation(
        this.ruAdminApi.deleteAllRuIndications([ruIndication.id!]),
        $localize`:@@toast_delete_success:Der Eintrag wurde erfolgreich gelöscht.`,
      );
    } else if (event.result && ruIndication.id) {
      await this.runMutation(
        this.ruAdminApi.putRuIndication(ruIndication.id, event.result),
        $localize`:@@ru_indications_toast_edit_success:Der Hinweis wurde erfolgreich gespeichert.`,
        event.result.scope.companies,
      );
    }
  }

  async add(): Promise<void> {
    const event = await firstValueFrom(this.dialogService.open<RuIndicationDialog, RuIndication>(RuIndicationDialog, {data: {templates: this.ruIndicationTemplatesResource.value()?.data}}).afterClosed);
    if (event.result) {
      await this.runMutation(
        this.ruAdminApi.postRuIndication(event.result),
        $localize`:@@ru_indications_toast_create_success:Der Hinweis wurde erfolgreich erstellt.`,
        event.result.scope.companies,
      );
    }
  }

  async deleteAll(ruIndications: RuIndication[]): Promise<void> {
    await this.runMutation(
      this.ruAdminApi.deleteAllRuIndications(ruIndications.map((n) => n.id!)),
      $localize`:@@toast_delete_all_success:Die Einträge wurden erfolgreich gelöscht.`,
    );
  }

  protected override reload(): void {
    this.ruAdminApi.ruIndications.reload();
  }
}

