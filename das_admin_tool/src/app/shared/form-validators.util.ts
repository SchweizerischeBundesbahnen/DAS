import {
  AbstractControl,
  FormControl,
  FormGroup,
  ValidationErrors,
  ValidatorFn,
} from '@angular/forms';

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

type StringFormControl = FormControl<string>;
type RecordFormGroup = FormGroup<Record<string, StringFormControl>>;

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
  const controls = Object.values((control as RecordFormGroup).controls);
  const values = controls.map((control) => !!control.value.trim());
  for (const control of controls) {
    if (values.includes(true)) {
      if (control.value.trim()) {
        removeError(control, 'languageRequired');
      } else {
        addError(control, 'languageRequired');
      }
    } else {
      removeError(control, 'languageRequired');
    }
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
  const deControls = Object.values((control.get('de') as RecordFormGroup).controls);
  const deEmpty = deControls.every((control) => !control.value.trim());
  const frControls = Object.values((control.get('fr') as RecordFormGroup).controls);
  const frEmpty = frControls.every((control) => !control.value.trim());
  const itControls = Object.values((control.get('it') as RecordFormGroup).controls);
  const itEmpty = itControls.every((control) => !control.value.trim());
  return deEmpty && frEmpty && itEmpty ? { oneLanguageRequired: true } : null;
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
export function titleRequired(...fields: string[]): ValidatorFn {
  return (control: AbstractControl): ValidationErrors | null => {
    const titleControl = control.get('title') as StringFormControl;
    const title = titleControl.value.trim();
    const values = fields.map((field) => !!(control.get(field) as StringFormControl).value.trim());
    if (values.includes(true) && !title) {
      addError(titleControl, 'titleRequired');
    } else {
      removeError(titleControl, 'titleRequired');
    }
    return null;
  };
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
  return !control.value || URL.canParse((control as StringFormControl).value)
    ? null
    : { url: true };
}
