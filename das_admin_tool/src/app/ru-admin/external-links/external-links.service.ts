import { inject, Injectable } from '@angular/core';
import { ExternalLink, RuAdminApi } from '../ru-admin-api';
import {
  ExternalLinkDialog,
  ExternalLinkDialogEditResult,
} from './external-link-dialog/external-link-dialog';
import { BaseDialogService } from '../base-dialog.service';
import { firstValueFrom } from 'rxjs';

@Injectable({ providedIn: 'root' })
export class ExternalLinksService extends BaseDialogService {
  private readonly ruAdminApi = inject(RuAdminApi);
  public readonly externalLinksResource = this.ruAdminApi.externalLinks;

  public async edit(externalLink: ExternalLink): Promise<void> {
    const { result } = await firstValueFrom(
      this.dialogService.open<ExternalLinkDialog, ExternalLinkDialogEditResult>(
        ExternalLinkDialog,
        { data: externalLink },
      ).afterClosed,
    );
    if (result === 'delete') {
      await this.runMutation(
        this.ruAdminApi.deleteExternalLinksByIds([externalLink.id!]),
        $localize`:@@external_links_toast_delete_success:Der externe Absprung wurde erfolgreich gelöscht.`,
      );
    } else if (result && externalLink.id) {
      await this.runMutation(
        this.ruAdminApi.putExternalLink(externalLink.id, result),
        $localize`:@@external_links_toast_edit_success:Der externe Absprung wurde erfolgreich gespeichert.`,
        result.companies,
      );
    }
  }

  public async add(): Promise<void> {
    const { result } = await firstValueFrom(
      this.dialogService.open<ExternalLinkDialog, ExternalLink>(ExternalLinkDialog).afterClosed,
    );
    if (result) {
      await this.runMutation(
        this.ruAdminApi.postExternalLink(result),
        $localize`:@@external_links_toast_create_success:Der externe Absprung wurde erfolgreich erstellt.`,
        result.companies,
      );
    }
  }

  public async deleteAllByIds(ids: number[]): Promise<void> {
    await this.runMutation(
      this.ruAdminApi.deleteExternalLinksByIds(ids),
      $localize`:@@external_links_toast_delete_all_success:Die externen Absprünge wurden erfolgreich gelöscht.`,
    );
  }

  protected override reload(): void {
    this.externalLinksResource.reload();
  }
}
