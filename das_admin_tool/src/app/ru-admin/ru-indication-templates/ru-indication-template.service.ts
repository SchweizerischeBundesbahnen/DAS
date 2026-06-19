import { inject, Injectable } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { BaseDialogService } from '../base-dialog.service';
import { RuAdminApi, RuIndicationTemplate } from '../ru-admin-api';
import {
  RuIndicationTemplateDialog,
  RuIndicationTemplateDialogEditResult,
} from './ru-indication-template-dialog/ru-indication-template-dialog';

@Injectable({ providedIn: 'root' })
export class RuIndicationTemplateService extends BaseDialogService {
  private readonly ruAdminApi = inject(RuAdminApi);
  readonly ruIndicationTemplatesResource = this.ruAdminApi.ruIndicationTemplates;

  async edit(ruIndicationTemplate: RuIndicationTemplate) {
    const event = await firstValueFrom(
      this.dialogService.open<RuIndicationTemplateDialog, RuIndicationTemplateDialogEditResult>(
        RuIndicationTemplateDialog,
        { data: ruIndicationTemplate },
      ).afterClosed,
    );
    if (event.result === 'delete') {
      await this.runMutation(
        this.ruAdminApi.deleteAllRuIndicationTemplate([ruIndicationTemplate.id!]),
        $localize`:@@ru_indication_templates_toast_delete_success:Der Titel & Text wurde erfolgreich gelöscht.`,
      );
    } else if (event.result && ruIndicationTemplate.id) {
      await this.runMutation(
        this.ruAdminApi.putRuIndicationTemplate(ruIndicationTemplate.id, event.result),
        $localize`:@@ru_indication_templates_toast_edit_success:Der Titel & Text wurde erfolgreich gespeichert.`,
      );
    }
  }

  async add() {
    const event = await firstValueFrom(
      this.dialogService.open<RuIndicationTemplateDialog, RuIndicationTemplate>(
        RuIndicationTemplateDialog,
      ).afterClosed,
    );
    if (event.result) {
      await this.runMutation(
        this.ruAdminApi.postRuIndicationTemplate(event.result),
        $localize`:@@ru_indication_templates_toast_create_success:Der Titel & Text wurde erfolgreich erstellt.`,
      );
    }
  }

  async deleteAll(ruIndicationTemplates: RuIndicationTemplate[]): Promise<void> {
    await this.runMutation(
      this.ruAdminApi.deleteAllRuIndicationTemplate(ruIndicationTemplates.map((n) => n.id!)),
      $localize`:@@ru_indication_templates_toast_delete_all_success:Die Texte & Titel wurden erfolgreich gelöscht.`,
    );
  }

  protected reload() {
    this.ruAdminApi.ruIndicationTemplates.reload();
  }
}
