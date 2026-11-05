import { Component, inject } from '@angular/core';
import { SbbLoadingIndicatorCircle } from '@sbb-esta/lyne-angular/loading-indicator-circle';
import { PageHeader } from '~shared/components/page-header/page-header';
import { CompaniesTable } from './companies-table/companies-table';
import { CompanyService } from './company.service';

@Component({
  selector: 'app-companies',
  imports: [PageHeader, SbbLoadingIndicatorCircle, CompaniesTable],
  templateUrl: './companies.html',
  styleUrl: './companies.css',
})
export class Companies {
  protected readonly companyService = inject(CompanyService);

  protected readonly title = $localize`:@@companies_title:EVUs`;
}
