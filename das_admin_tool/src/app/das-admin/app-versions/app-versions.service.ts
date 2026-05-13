import {inject, Injectable} from '@angular/core';
import {AppVersion, DasAdminApi} from '../das-admin-api';
import {AppVersionDialog, VersionDialogEditResult} from './app-version-dialog/app-version-dialog';
import {firstValueFrom, Observable} from 'rxjs';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {ToastService} from '../../shared/toast-service';
import {HttpErrorResponse} from '@angular/common/http';

@Injectable({
  providedIn: 'root',
})
export class AppVersionsService {

  private readonly dasAdminApi = inject(DasAdminApi);
  private readonly dialogService = inject(SbbDialogService);
  private readonly toastService = inject(ToastService);

  readonly appVersionsResource = this.dasAdminApi.appVersions;

  async edit(appVersion: AppVersion) {
    const event = await firstValueFrom(this.dialogService.open<AppVersionDialog, VersionDialogEditResult>(AppVersionDialog, {data: appVersion}).afterClosed);
    if (event.result === 'delete') {
      await this.runMutation(this.dasAdminApi.deleteAppVersion(appVersion.id!), $localize`:@@app_versions_toast_delete_success:Die blockierte App Version wurde erfolgreich gelöscht.`)
    } else if (event.result && appVersion.id) {
      await this.runMutation(this.dasAdminApi.putAppVersion(appVersion.id, event.result), $localize`:@@app_versions_toast_edit_success:Die blockierte App Version wurde erfolgreich gespeichert.`);
    }
  }

  async add() {
    const event = await firstValueFrom(this.dialogService.open<AppVersionDialog, AppVersion>(AppVersionDialog).afterClosed);
    if (event.result) {
      await this.runMutation(this.dasAdminApi.postAppVersion(event.result), $localize`:@@app_versions_toast_create_success:Die blockierte App Version wurde erfolgreich erstellt.`);
    }
  }

  private reloadAppVersions() {
    this.dasAdminApi.appVersions.reload()
  }

  private async runMutation(request: Observable<unknown>, successMessage: string): Promise<void> {
    await firstValueFrom(request)
      .then(() => {
        this.toastService.success(successMessage);
        this.reloadAppVersions();
      })
      .catch(e => this.handleApiError(e));
  }

  private handleApiError(e: unknown) {
    if (e instanceof HttpErrorResponse && e.error.status === 409) {
      this.toastService.error($localize`:@@app_versions_toast_conflict_error:Diese App Version existiert bereits.`);
    } else {
      this.toastService.error($localize`:@@app_versions_toast_error:Beim Speichern ist ein Fehler aufgetreten.`)
    }
  }
}
