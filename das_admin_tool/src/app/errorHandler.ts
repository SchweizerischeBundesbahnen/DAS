import {ErrorHandler} from '@angular/core';

export class ReportToInstanaErrorHandler implements ErrorHandler {
  handleError(error: string | Error) {
    if (typeof ineum !== 'undefined') {
      ineum('reportError', error);
    }
    // Continue to log caught errors to the console
    console.error('report', error);
  }
}
