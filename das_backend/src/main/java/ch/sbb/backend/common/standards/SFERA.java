package ch.sbb.backend.common.standards;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * Data exchange specification by IRS 90940 Ed. 2 or derrived NSPs.
 */
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface SFERA {

    boolean nsp() default false;
}
