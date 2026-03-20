import {inject, Injectable} from '@angular/core';
import {AppVersion, DasAdminApi} from '../das-admin-api';
import {AppVersionDialog, VersionDialogEditResult} from './app-version-dialog/app-version-dialog';
import {firstValueFrom} from 'rxjs';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {ToastService} from '../../shared/toast-service';

@Injectable({
  providedIn: 'root',
})
export class AppVersionsService {

  private readonly dasAdminApi = inject(DasAdminApi);
  private readonly dialogService = inject(SbbDialogService);
  private readonly toastService = inject(ToastService);

  readonly appVersionsResource = this.dasAdminApi.appVersions;

  private reloadAppVersions() {
    this.dasAdminApi.appVersions.reload()
  }

  async edit(appVersion: AppVersion) {
    try {
      const event = await firstValueFrom(this.dialogService.open<AppVersionDialog, VersionDialogEditResult>(AppVersionDialog, {data: appVersion}).afterClosed);
      if (event.result === 'delete') {
        await firstValueFrom(this.dasAdminApi.deleteAppVersion(appVersion.id!));
        this.toastService.success($localize`:@@appVersionDeleteSuccess:Die blockierte App Version wurde erfolgreich gelöscht.`);
        this.reloadAppVersions();
      } else if (event.result && appVersion.id) {
        await firstValueFrom(this.dasAdminApi.putAppVersion(appVersion.id, event.result));
        this.toastService.success($localize`:@@appVersionEditSuccess:Die blockierte App Version wurde erfolgreich gespeichert.`);
        this.reloadAppVersions();
      }
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      // todo error message? (especially constraint! duplicate version)
      this.toastService.error($localize`:@@appVersionEditError:Beim Speichern der blockierten App Version ist ein Fehler aufgetreten.`)
    }
  }

  async add() {
    try {
      const event = await firstValueFrom(this.dialogService.open<AppVersionDialog, AppVersion>(AppVersionDialog).afterClosed);
      if (event.result) {
        await firstValueFrom(this.dasAdminApi.postAppVersion(event.result));
        this.toastService.success($localize`:@@appVersionAddSuccess:Die blockierte App Version wurde erfolgreich erstellt.`);
        this.reloadAppVersions();
      }
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
    } catch (error) {
      // todo error message? (especially constraint! duplicate version)
      this.toastService.error($localize`:@@appVersionAddError:Beim Erstellen der blockierten App Version ist ein Fehler aufgetreten.`)
    }
  }
}
