import { ReadonlyFieldState } from '@angular/forms/signals';

export function hasError(state: ReadonlyFieldState<unknown>, errorKind: string) {
  return state.errors().some((error) => error.kind === errorKind);
}
