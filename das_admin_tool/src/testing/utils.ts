import { ReadonlyFieldState } from '@angular/forms/signals';

export function expectError(state: ReadonlyFieldState<unknown>, errorKind: string) {
  return state.errors().some((error) => error.kind === errorKind);
}
