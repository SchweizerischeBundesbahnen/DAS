import { Component, inject, signal } from '@angular/core';
import { form, FormField, pattern, required } from '@angular/forms/signals';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbSelectModule } from '@sbb-esta/lyne-angular/select';
import { InternalCompany } from '~app/das-admin/das-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { TenantService } from './tenant.service';

export interface CompanyData {
  code: string;
  shortName: string;
  tenantId: string;
}

export type CompanyDialogEditResult = InternalCompany | 'delete';

@Component({
  selector: 'app-company-dialog',
  imports: [FormField, SbbFormFieldModule, SbbSelectModule, BaseDialog],
  templateUrl: './company-dialog.html',
  styleUrl: './company-dialog.css',
})
export class CompanyDialog {
  private readonly tenantService = inject(TenantService);

  protected readonly dialogData =
    inject<InternalCompany>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;

  private static readonly COMPANY_REGEX = /^(?!0000)\d{4}$/;

  protected readonly dialogTitle: string;

  protected readonly companyModel = signal<CompanyData>({
    code: '',
    shortName: '',
    tenantId: '',
  });
  protected readonly companyForm = form(this.companyModel, (company) => {
    required(company.code, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
    pattern(company.code, CompanyDialog.COMPANY_REGEX, {
      message: $localize`:@@company_form_field_error_pattern:Feld muss einen vierstelligen Code beinhalten (nicht 0000)`,
    });

    required(company.shortName, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });

    required(company.tenantId, {
      message: $localize`:@@form_field_error_required:Feld darf nicht leer sein`,
    });
  });

  protected readonly tenants = this.tenantService.tenants;

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = isEdit
      ? $localize`:@@company_dialog_title_edit:EVU bearbeiten`
      : $localize`:@@company_dialog_title_create:EVU erfassen`;

    if (isEdit && this.dialogData) {
      this.companyModel.update(() => ({
        code: this.dialogData!.code,
        shortName: this.dialogData!.shortName,
        tenantId: this.dialogData!.tenantId,
      }));
    }
  }
}
