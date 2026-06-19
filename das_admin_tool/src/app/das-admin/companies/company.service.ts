import { HttpErrorResponse } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import { BaseDialogService } from '~ru-admin/base-dialog.service';
import { DasAdminApi, InternalCompany } from '../das-admin-api';
import { CompanyDialog, CompanyDialogEditResult } from './company-dialog/company-dialog';

@Injectable({ providedIn: 'root' })
export class CompanyService extends BaseDialogService {
  private readonly dasAdminApi = inject(DasAdminApi);
  public readonly companiesResource = this.dasAdminApi.companiesResource;

  public async edit(company: InternalCompany): Promise<void> {
    const { result } = await firstValueFrom(
      this.dialogService.open<CompanyDialog, CompanyDialogEditResult>(CompanyDialog, {
        data: company,
      }).afterClosed,
    );
    if (result === 'delete') {
      await this.runMutation(
        this.dasAdminApi.deleteCompanyById(company.id),
        $localize`:@@companies_toast_delete_success:Die EVU wurde erfolgreich gelöscht.`,
      );
    } else if (result && company.id) {
      await this.runMutation(
        this.dasAdminApi.putCompany(company.id, result),
        $localize`:@@companies_toast_edit_success:Die EVU wurde erfolgreich gespeichert.`,
      );
    }
  }

  public async add() {
    const event = await firstValueFrom(
      this.dialogService.open<CompanyDialog, InternalCompany>(CompanyDialog).afterClosed,
    );
    if (event.result) {
      await this.runMutation(
        this.dasAdminApi.postCompany(event.result),
        $localize`:@@companies_toast_create_success:Die EVU wurde erfolgreich erstellt.`,
      );
    }
  }

  protected override reload(): void {
    this.companiesResource.reload();
  }

  protected override handleApiError(e: unknown) {
    if (e instanceof HttpErrorResponse && e.status === 409) {
      this.toastService.error(
        $localize`:@@companies_toast_conflict_error:Diese EVU existiert bereits.`,
      );
    } else {
      super.handleApiError(e);
    }
  }
}
