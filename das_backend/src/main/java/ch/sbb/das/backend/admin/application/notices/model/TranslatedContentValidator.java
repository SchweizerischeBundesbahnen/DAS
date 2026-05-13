package ch.sbb.das.backend.admin.application.notices.model;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

/**
 * Validator for checking that at least one language content is provided. Works with any class implementing {@link TranslatedContentRequest}.
 */
public class TranslatedContentValidator implements ConstraintValidator<ValidTranslatedContent, TranslatedContentRequest> {

    @Override
    public boolean isValid(TranslatedContentRequest request, ConstraintValidatorContext context) {
        if (request == null) {
            return true;
        }

        return request.de() != null || request.fr() != null || request.it() != null;
    }
}

