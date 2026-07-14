import {inject, Injectable} from '@angular/core';
import {firstValueFrom} from 'rxjs';
import {RuAdminApi, RuFeature} from '../ru-admin-api';
import {
  RuFeatureDialogEditResult,
  RuFeatureToggleDialog
} from './ru-feature-toggle-dialog/ru-feature-toggle-dialog.component';
import {BaseDialogService} from '../base-dialog.service';

@Injectable({
  providedIn: 'root',
})
export class RuFeatureService extends BaseDialogService {
  private readonly ruAdminApi = inject(RuAdminApi);
  readonly ruFeaturesResource = this.ruAdminApi.ruFeatures;

  async edit(ruFeature: RuFeature): Promise<void> {
    const event = await firstValueFrom(this.dialogService.open<RuFeatureToggleDialog, RuFeatureDialogEditResult>(RuFeatureToggleDialog, {data: ruFeature}).afterClosed);
    if (event.result === 'delete') {
      await this.runMutation(
        this.ruAdminApi.deleteRuFeaturesByIds([ruFeature.id!]),
        $localize`:@@toast_delete_success:Der Eintrag wurde erfolgreich gelöscht.`,
      );
    } else if (event.result && ruFeature.id) {
      await this.runMutation(
        this.ruAdminApi.putRuFeature(ruFeature.id, event.result),
        $localize`:@@ru_feature_toggles_toast_edit_success:Das Feature wurde erfolgreich gespeichert.`,
        [event.result.companyCode],
      );
    }
  }

  async add(): Promise<void> {
    const event = await firstValueFrom(this.dialogService.open<RuFeatureToggleDialog, RuFeature>(RuFeatureToggleDialog).afterClosed);
    if (event.result) {
      await this.runMutation(
        this.ruAdminApi.postRuFeature(event.result),
        $localize`:@@ru_feature_toggles_toast_create_success:Das Feature wurde erfolgreich erstellt.`,
        [event.result.companyCode],
      );
    }
  }

  protected override reload(): void {
    this.ruAdminApi.ruFeatures.reload();
  }
}
