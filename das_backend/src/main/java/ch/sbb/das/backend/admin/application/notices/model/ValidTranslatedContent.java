package ch.sbb.das.backend.admin.application.notices.model;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = TranslatedContentValidator.class)
@Documented
public @interface ValidTranslatedContent {

    String message() default "At least one language content (de, fr or it) must be provided.";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}

