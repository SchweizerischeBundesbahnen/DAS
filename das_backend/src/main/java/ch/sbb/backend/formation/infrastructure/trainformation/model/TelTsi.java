package ch.sbb.backend.formation.infrastructure.trainformation.model;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * All these elements/attributes are imported from the TAF/TAP XSD
 * <p>
 * - SFERA v3.00 imports TAF/TAP XSD v3.5.0.0 - Further versions will update the import - The namespace is “teltsi:” (i.e. “Telematics TSI”)
 */
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface TelTsi {

}
