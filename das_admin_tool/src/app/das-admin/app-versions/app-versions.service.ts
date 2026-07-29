import { HttpErrorResponse } from '@angular/common/http';
import { inject, Service } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { BaseDialogService } from '~ru-admin/base-dialog.service';
import { AppVersion, DasAdminApi } from '../das-admin-api';
import { AppVersionDialog, VersionDialogEditResult } from './app-version-dialog/app-version-dialog';

@Service()
export class AppVersionsService extends BaseDialogService {
  private readonly dasAdminApi = inject(DasAdminApi);
  readonly appVersionsResource = this.dasAdminApi.appVersions;

  async edit(appVersion: AppVersion) {
    const event = await firstValueFrom(
      this.dialogService.open<AppVersionDialog, VersionDialogEditResult>(AppVersionDialog, {
        data: appVersion,
      }).afterClosed,
    );
    if (event.result === 'delete') {
      await this.runMutation(
        this.dasAdminApi.deleteAppVersion(appVersion.id!),
        $localize`:@@app_versions_toast_delete_success:Die blockierte App Version wurde erfolgreich gelöscht.`,
      );
    } else if (event.result && appVersion.id) {
      await this.runMutation(
        this.dasAdminApi.putAppVersion(appVersion.id, event.result),
        $localize`:@@app_versions_toast_edit_success:Die blockierte App Version wurde erfolgreich gespeichert.`,
      );
    }
  }

  async add() {
    const event = await firstValueFrom(
      this.dialogService.open<AppVersionDialog, AppVersion>(AppVersionDialog).afterClosed,
    );
    if (event.result) {
      await this.runMutation(
        this.dasAdminApi.postAppVersion(event.result),
        $localize`:@@app_versions_toast_create_success:Die blockierte App Version wurde erfolgreich erstellt.`,
      );
    }
  }

  protected override reload(): void {
    this.dasAdminApi.appVersions.reload();
  }

  protected override handleApiError(e: unknown) {
    if (e instanceof HttpErrorResponse && e.status === 409) {
      this.toastService.error(
        $localize`:@@app_versions_toast_conflict_error:Diese App Version existiert bereits.`,
      );
    } else {
      super.handleApiError(e);
    }
  }
}
