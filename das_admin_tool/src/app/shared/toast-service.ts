import {inject, Injectable} from '@angular/core';
import {SbbToast, SbbToastService} from '@sbb-esta/lyne-angular/toast';

const TOAST_CONFIG_SUCCESS = {
  setupContainer: (toast: SbbToast) => {
    toast.iconName = 'circle-tick-small';
  },
};

const TOAST_CONFIG_ERROR = {
  setupContainer: (toast: SbbToast) => {
    toast.iconName = 'circle-cross-small';
  },
};

@Injectable({
  providedIn: 'root',
})
export class ToastService {
  private readonly toastService = inject(SbbToastService);

  success(message: string) {
    this.toastService.open(message, TOAST_CONFIG_SUCCESS);
  }

  error(message: string) {
    this.toastService.open(message, TOAST_CONFIG_ERROR);
  }
}
