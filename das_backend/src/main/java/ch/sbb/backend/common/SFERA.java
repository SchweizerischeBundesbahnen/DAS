package ch.sbb.backend.common;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Given by IRS 90940 Ed. 2 or derrived NSPs.
 */
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface SFERA {

    boolean nsp() default false;
}
