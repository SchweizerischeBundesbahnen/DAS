import { Component, input } from '@angular/core';
import { DatePipe } from '@angular/common';
import { SbbStepperModule } from '@sbb-esta/lyne-angular/stepper';
import { SbbTitleModule } from '@sbb-esta/lyne-angular/title';
import { Auditable } from './auditable';

@Component({
  selector: 'app-audit',
  imports: [SbbTitleModule, SbbStepperModule, DatePipe],
  templateUrl: './audit.html',
  styleUrl: './audit.css',
})
export class Audit {
  readonly data = input<Auditable>();
}
