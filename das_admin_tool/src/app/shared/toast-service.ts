import {inject, Injectable} from '@angular/core';
import {SbbToast, SbbToastContainer, SbbToastService} from '@sbb-esta/lyne-angular/toast';
import {SbbOverlayConfig} from '@sbb-esta/lyne-angular/core/overlay';

const TOAST_CONFIG_SUCCESS = {
  setupContainer: (toast: SbbToast) => {
    toast.iconName = 'circle-tick-small';
    toast.timeout = 20_000;
  },
} as SbbOverlayConfig<SbbToastContainer, SbbToast>;

const TOAST_CONFIG_ERROR = {
  setupContainer: (toast: SbbToast) => {
    toast.iconName = 'circle-cross-small';
    toast.timeout = 20_000;
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
