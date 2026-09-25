import {
  LogicFn,
  PathKind,
  SchemaPath,
  SchemaPathRules,
  validate,
  validateTree,
} from '@angular/forms/signals';

interface BaseConfig<TValue, TPathKind extends PathKind = PathKind.Root> {
  message?: string;
  when?: NoInfer<LogicFn<TValue, boolean, TPathKind>>;
}

function hasValue(value: unknown): boolean {
  return typeof value === 'string' ? value.trim().length > 0 : !!value;
}

function isObject(field: unknown): field is object {
  return field instanceof Object && !Array.isArray(field);
}

/**
 * @description
 * Validator that requires the field to have a non empty array.
 *
 * @returns An error map with the `kind` property set to `arrayRequired`
 * if the validation check fails, otherwise `null`.
 *
 */
export function arrayRequired<TValue extends unknown[], TPathKind extends PathKind = PathKind.Root>(
  path: SchemaPath<TValue, SchemaPathRules.Supported, TPathKind>,
  config?: BaseConfig<TValue>,
): void {
  validate(path, ({ value }) => {
    return value().length === 0 ? { kind: 'arrayRequired', message: config?.message } : null;
  });
}

/**
 * @description
 * Validator that requires all fields of a language tree to have a value if one of them has a value.
 *
 * Adds an error map with the `kind` property set to 'languageRequired'
 * to the child fields.
 *
 * @returns `null`.
 *
 */
export function languageRequired<
  TValue extends { title: string },
  TPathKind extends PathKind = PathKind.Root,
>(
  path: SchemaPath<TValue, SchemaPathRules.Supported, TPathKind>,
  config?: BaseConfig<TValue>,
): void {
  validateTree(path, ({ value, fieldTreeOf }) => {
    const hasAnyValue = Object.values(value()).some((field) => hasValue(field));

    const errors = [];
    for (const [key, field] of Object.entries(value())) {
      if (hasAnyValue && !hasValue(field)) {
        errors.push({
          kind: 'languageRequired',
          message: config?.message,
          // @ts-expect-error types are not compatible, but it does work
          // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
          fieldTree: fieldTreeOf(path[key]),
        });
      }
    }
    return errors.length > 0 ? errors : null;
  });
}

/**
 * @description
 * Validator that requires one field of a language tree to have a value.
 *
 * @returns An error map with the `kind` property set to 'oneLanguageRequired'
 * if the validation check fails, otherwise `null`.
 *
 */
export function oneLanguageRequired<
  TValue extends object,
  TPathKind extends PathKind = PathKind.Root,
>(
  path: SchemaPath<TValue, SchemaPathRules.Supported, TPathKind>,
  config?: BaseConfig<TValue>,
): void {
  validate(path, ({ value }) => {
    const tree = value() as {
      de: Record<string, unknown>;
      fr: Record<string, unknown>;
      it: Record<string, unknown>;
      [key: string]: unknown;
    };
    const languageTrees = Object.values(tree).filter(isObject);
    const hasAnyLanguageValue = languageTrees.some((languageTree) =>
      Object.values(languageTree).some((field) => hasValue(field)),
    );

    return hasAnyLanguageValue ? null : { kind: 'oneLanguageRequired', message: config?.message };
  });
}

/**
 * @description
 * Validator that requires 'title' field to have a value
 * if one of the other defined fields have a value.
 *
 * Adds an error map with the `kind` property set to `titleRequired`
 * to the child fields.
 *
 * @returns `null`.
 *
 */
export function titleRequired<TValue extends object, TPathKind extends PathKind = PathKind.Root>(
  path: SchemaPath<TValue, SchemaPathRules.Supported, TPathKind>,
  config?: BaseConfig<TValue>,
): void {
  validateTree(path, ({ value, fieldTreeOf }) => {
    const tree = value() as { title: string; [key: string]: unknown };
    const titleField = tree.title;
    const hasOtherValue = Object.entries(tree).some(
      ([key, otherField]) => key !== 'title' && hasValue(otherField),
    );
    const isMissingTitle = hasOtherValue && !hasValue(titleField);

    if (isMissingTitle) {
      return {
        kind: 'titleRequired',
        message: config?.message,
        // @ts-expect-error types are not compatible, but it does work
        // eslint-disable-next-line @typescript-eslint/no-unsafe-argument
        fieldTree: fieldTreeOf(path.title),
      };
    }
    return null;
  });
}

/**
 * @description
 * Validator that requires the field to be a URL.
 *
 * @returns An error map with the `kind` property set to `url`
 * if the validation check fails, otherwise `null`.
 *
 */
export function url<TValue extends string, TPathKind extends PathKind = PathKind.Root>(
  path: SchemaPath<TValue, SchemaPathRules.Supported, TPathKind>,
  config?: BaseConfig<TValue>,
): void {
  validate(path, ({ value }) => {
    return !value() || URL.canParse(value()) ? null : { kind: 'url', message: config?.message };
  });
}
