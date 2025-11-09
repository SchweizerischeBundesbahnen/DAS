package ch.sbb.das.backend.restapi.iam.ssoutils;

import com.fasterxml.jackson.core.JsonParseException;
import com.fasterxml.jackson.databind.JsonMappingException;
import java.io.IOException;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
public interface MappingErrorHandler {

    Logger LOGGER = LoggerFactory.getLogger(MappingErrorHandler.class);

    String JSON_EMPTYLIST = "[]";

    /**
     * Concerns JSON-Mapping
     *
     * @return Default Mapping-Error-Handler.
     */
    static MappingErrorHandler createDefaultMappingErrorHandler() {
        return new MappingErrorHandler() {
        };
    }

    default RequesterMappingException handle(JsonMappingException ex, Class<?> clazz, String responseBody) {
        final String text = "Mapping failed! JSON to Model (POJO): " + clazz.getName() + ", body=" + responseBody;
        return toRequesterMappingException(text, ex);
    }

    default RequesterMappingException handle(JsonParseException ex, Class<?> clazz, String responseBody) {
        final String text = "Parsing failed! JSON to Model (POJO): " + clazz + ", body=" + responseBody;
        return toRequesterMappingException(text, ex);
    }

    default RequesterMappingException handle(IOException ex, Class<?> clazz) {
        final String text = "Unexpected I/O fault! JSON to raw Model (POJO): " + clazz;
        return toRequesterMappingException(text, ex);
    }

    default void handleEmptyResponse(String body) {
        // default behaviour: nothing happens.
        if (StringUtils.isEmpty(body)) {
            LOGGER.warn("<empty body>");
        } else if (JSON_EMPTYLIST.equals(body)) {
            LOGGER.debug("<empty JSON List>");
        }
    }

    default RequesterMappingException toRequesterMappingException(String text, Exception ex) {
        return new RequesterMappingException(text, ex);
    }

    default RequesterMappingException toRequesterMappingException(String text) {
        return new RequesterMappingException(text);
    }
}
