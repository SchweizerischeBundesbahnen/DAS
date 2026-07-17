import { AbstractControl, FormGroup, ValidationErrors } from '@angular/forms';

function hasValue(value: unknown): boolean {
  return typeof value === 'string' ? value.trim().length > 0 : !!value;
}

function isFormGroup(control: AbstractControl): control is FormGroup {
  return control instanceof FormGroup;
}

function addError(control: AbstractControl, key: string) {
  const errors = control.errors ?? {};
  errors[key] = true;
  control.setErrors(errors);
}

function removeError(control: AbstractControl, key: string) {
  const errors = control.errors ?? {};
  delete errors[key];
  control.setErrors(Object.keys(errors).length > 0 ? errors : null);
}

/**
 * @description
 * Validator that requires all controls of a group to have a value if one of them has a value.
 *
 * Adds an error map with the `languageRequired` property set to `true`
 * to the child controls.
 *
 * @returns `null`.
 *
 */
export function languageRequired(control: AbstractControl): ValidationErrors | null {
  const controls = Object.values((control as FormGroup).controls);
  const hasAnyValue = controls.some((childControl) => hasValue(childControl.value));

  for (const childControl of controls) {
    if (hasAnyValue && !hasValue(childControl.value)) {
      addError(childControl, 'languageRequired');
      continue;
    }
    removeError(childControl, 'languageRequired');
  }
  return null;
}

/**
 * @description
 * Validator that requires one control of a language group to have a value.
 *
 * @returns An error map with the `oneLanguageRequired` property set to `true`
 * if the validation check fails, otherwise `null`.
 *
 */
export function oneLanguageRequired(control: AbstractControl): ValidationErrors | null {
  const languageGroups = Object.values((control as FormGroup).controls).filter(isFormGroup);
  const hasAnyLanguageValue = languageGroups.some((languageGroup) =>
    Object.values(languageGroup.controls).some((childControl) => hasValue(childControl.value)),
  );

  return hasAnyLanguageValue ? null : { oneLanguageRequired: true };
}

/**
 * @description
 * Validator that requires 'title' control to have a value
 * if one of the other defined controls have a value.
 *
 * Adds an error map with the `titleRequired` property set to `true`
 * to the child controls.
 *
 * @returns `null`.
 *
 */
export function titleRequired(control: AbstractControl): ValidationErrors | null {
  const formGroup = control as FormGroup;
  const titleControl = formGroup.get('title');
  const hasOtherValue = Object.entries(formGroup.controls).some(
    ([key, childControl]) => key !== 'title' && hasValue(childControl.value),
  );
  const isMissingTitle = !!titleControl && hasOtherValue && !hasValue(titleControl.value);

  if (titleControl) {
    if (isMissingTitle) {
      addError(titleControl, 'titleRequired');
    } else {
      removeError(titleControl, 'titleRequired');
    }
  }

  return null;
}

/**
 * @description
 * Validator that requires the control to be a URL.
 *
 * @returns An error map with the `url` property set to `true`
 * if the validation check fails, otherwise `null`.
 *
 */
export function url(control: AbstractControl): ValidationErrors | null {
  return !control.value || URL.canParse(control.value) ? null : { url: true };
}
