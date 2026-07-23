import { Component, inject } from '@angular/core';
import { SbbSecondaryButton } from '@sbb-esta/lyne-angular/button';
import { SbbLoadingIndicatorCircle } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { SbbTitle } from '@sbb-esta/lyne-angular/title';
import { CompaniesTable } from './companies-table/companies-table';
import { CompanyService } from './company.service';

@Component({
  selector: 'app-companies',
  imports: [SbbTitle, SbbSecondaryButton, SbbLoadingIndicatorCircle, CompaniesTable],
  templateUrl: './companies.html',
  styleUrl: './companies.css',
})
export class Companies {
  protected readonly companyService = inject(CompanyService);
}
