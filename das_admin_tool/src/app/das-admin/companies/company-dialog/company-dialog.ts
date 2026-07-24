import { Component, inject } from '@angular/core';
import {
  FormControl,
  NonNullableFormBuilder,
  ReactiveFormsModule,
  Validators,
} from '@angular/forms';
import { SBB_OVERLAY_DATA } from '@sbb-esta/lyne-angular/core';
import { SbbFormFieldModule } from '@sbb-esta/lyne-angular/form-field';
import { SbbSelectModule } from '@sbb-esta/lyne-angular/select';
import { InternalCompany } from '~app/das-admin/das-admin-api';
import { BaseDialog } from '~shared/base-dialog/base-dialog.component';
import { TenantService } from './tenant.service';

export interface FormGroupCompany {
  code: FormControl<string>;
  shortName: FormControl<string>;
  tenantId: FormControl<string>;
}

export type CompanyDialogEditResult = InternalCompany | 'delete';

@Component({
  selector: 'app-company-dialog',
  imports: [ReactiveFormsModule, SbbFormFieldModule, SbbSelectModule, BaseDialog],
  templateUrl: './company-dialog.html',
  styleUrl: './company-dialog.css',
})
export class CompanyDialog {
  protected readonly dialogData =
    inject<InternalCompany>(SBB_OVERLAY_DATA, { optional: true }) ?? undefined;
  private readonly formBuilder = inject(NonNullableFormBuilder);
  private readonly tenantService = inject(TenantService);

  protected readonly dialogTitle: string;

  protected companyForm = this.formBuilder.group<FormGroupCompany>({
    code: this.formBuilder.control('', [Validators.required, Validators.pattern(/^\d{4}$/)]),
    shortName: this.formBuilder.control('', Validators.required),
    tenantId: this.formBuilder.control('', Validators.required),
  });

  protected readonly tenants = this.tenantService.tenants;

  constructor() {
    const isEdit = this.dialogData?.id !== undefined;
    this.dialogTitle = isEdit
      ? $localize`:@@company_dialog_title_edit:EVU bearbeiten`
      : $localize`:@@company_dialog_title_create:EVU erfassen`;

    if (isEdit && this.dialogData) {
      this.companyForm.patchValue(this.dialogData);
    }
  }
}
