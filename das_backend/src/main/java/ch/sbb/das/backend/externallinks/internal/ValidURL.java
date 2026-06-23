package ch.sbb.das.backend.externallinks.internal;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;
import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Target({ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = URLValidator.class)
@Documented
public @interface ValidURL {

    String message() default "must be a valid URL";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
