import {inject, Injectable} from '@angular/core';
import {ToastService} from '../../shared/toast-service';
import {SbbDialogService} from '@sbb-esta/lyne-angular/dialog';
import {firstValueFrom, Observable} from 'rxjs';
import {
  NoticeTemplateDialog,
  NoticeTemplateDialogEditResult
} from './notice-template-dialog/notice-template-dialog';
import {NoticeTemplate, RuAdminApi} from '../ru-admin-api';

@Injectable({
  providedIn: 'root',
})
export class NoticeTemplateService {

  private readonly ruAdminApi = inject(RuAdminApi);
  readonly noticeTemplatesResource = this.ruAdminApi.noticeTemplates;
  private readonly dialogService = inject(SbbDialogService);
  private readonly toastService = inject(ToastService);

  async edit(noticeTemplate: NoticeTemplate) {
    const event = await firstValueFrom(this.dialogService.open<NoticeTemplateDialog, NoticeTemplateDialogEditResult>(NoticeTemplateDialog, {data: noticeTemplate}).afterClosed);
    console.log(event);
    if (event.result === 'delete') {
      await this.runMutation(
        this.ruAdminApi.deleteNoticeTemplate(noticeTemplate.id!),
        $localize`:@@notice_templates_toast_delete_success:Der Titel & Text wurde erfolgreich gelöscht.`,
      );
    } else if (event.result && noticeTemplate.id) {
      await this.runMutation(
        this.ruAdminApi.putNoticeTemplate(noticeTemplate.id, event.result),
        $localize`:@@notice_templates_toast_edit_success:Der Titel & Text wurde erfolgreich gespeichert.`,
      );
    }
  }

  async add() {
    const event = await firstValueFrom(this.dialogService.open<NoticeTemplateDialog, NoticeTemplate>(NoticeTemplateDialog).afterClosed);
    if (event.result) {
      await this.runMutation(this.ruAdminApi.postNoticeTemplate(event.result), $localize`:@@notice_templates_toast_create_success:Der Titel & Text wurde erfolgreich erstellt.`);
    }
  }


  async deleteAll(noticeTemplates: NoticeTemplate[]): Promise<void> {
    await this.runMutation(
      this.ruAdminApi.deleteAllNoticeTemplate(noticeTemplates.map((n) => n.id!)),
      $localize`:@@notice_templates_toast_delete_all_success:Die Texte & Titel wurden erfolgreich gelöscht.`,
    );
  }

  private reloadNoticeTemplates() {
    this.ruAdminApi.noticeTemplates.reload()
  }

  private async runMutation(request: Observable<unknown>, successMessage: string): Promise<void> {
    await firstValueFrom(request)
      .then(() => {
        this.toastService.success(successMessage);
        this.reloadNoticeTemplates();
      })
      .catch(() => this.handleApiError());
  }

  private handleApiError(): void {
    this.toastService.error($localize`:@@notice_templates_toast_error:Beim Speichern ist ein Fehler aufgetreten.`);
  }
}
