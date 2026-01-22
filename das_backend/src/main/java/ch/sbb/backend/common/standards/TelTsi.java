package ch.sbb.backend.common.standards;

import java.lang.annotation.Documented;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;

/**
 * All these elements/attributes are imported from the TAF/TAP XSD
 * <ul>
 *  <li>SFERA v3.00 imports TAF/TAP XSD v3.5.0.0</li>
 *  <li>Further versions will update the import</li>
 *  <li>The namespace is “teltsi:” (i.e. “Telematics TSI”)</li>
 * </ul>
 */
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface TelTsi {

}
