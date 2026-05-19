package ch.sbb.das.backend.restapi.helper;

import com.fasterxml.jackson.annotation.JsonInclude.Include;
import lombok.experimental.UtilityClass;
import tools.jackson.databind.DeserializationFeature;
import tools.jackson.databind.SerializationFeature;
import tools.jackson.databind.cfg.DateTimeFeature;
import tools.jackson.databind.json.JsonMapper;

/**
 * Be aware: Instantiation is performance critical.
 * <p>
 * For Jackson annotated DTO's the following declaration is needed: Lombok AllArgsConstructor
 */
@UtilityClass
public final class ObjectMapperFactory {

    /**
     * @return tolerant JSON Mapper.
     */
    public static JsonMapper createMapper() {
        return createMapper(false);
    }

    /**
     * Create a JsonMapper to serialize or deserialize JSON.
     *
     * @param strict true: JSON to POJO or vice versa fails if not identical; false: JSON to POJO mapping tolerant
     * @return tolerant mapper, strongly recommended for PRODuction use!
     */
    public static JsonMapper createMapper(boolean strict) {
        return JsonMapper.builder()
            //TODO SFERA like (UTC)
            .disable(DateTimeFeature.WRITE_DATES_WITH_ZONE_ID)
            .disable(DateTimeFeature.WRITE_DATES_AS_TIMESTAMPS)
            .disable(DateTimeFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE)
            .configure(SerializationFeature.FAIL_ON_SELF_REFERENCES, strict)
            .configure(SerializationFeature.FAIL_ON_UNWRAPPED_TYPE_IDENTIFIERS, strict)
            .configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, strict)
            .configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, strict)
            .configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, strict)
            // do not transfer null properties in (POST) requests
            .changeDefaultPropertyInclusion(incl -> incl.withValueInclusion(Include.NON_NULL))
            .build();
    }
}
