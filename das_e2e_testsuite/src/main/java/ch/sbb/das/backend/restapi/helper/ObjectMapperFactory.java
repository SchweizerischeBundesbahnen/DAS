package ch.sbb.das.backend.restapi.helper;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.experimental.UtilityClass;

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
    public static ObjectMapper createMapper() {
        return createMapper(false);
    }

    /**
     * Create an ObjectMapper to serialize or deserialize JSON.
     *
     * @param strict true: JSON to POJO or vice versa fails if not identical; false: JSON to POJO mapping tolerant
     * @return tolerant mapper, strongly recommended for PRODuction use!
     */
    public static ObjectMapper createMapper(boolean strict) {
        // see ch.sbb.journey.utils.DateTimeUtils
        final ObjectMapper mapper = new ObjectMapper();
        //TODO SFERA like (UTC)
        mapper.configure(SerializationFeature.WRITE_DATES_WITH_ZONE_ID, false);
        mapper.configure(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS, false);
        mapper.configure(DeserializationFeature.ADJUST_DATES_TO_CONTEXT_TIME_ZONE, false);

        // needs jackson-datatype-jsr310
        mapper.registerModule(new JavaTimeModule());

        mapper.configure(SerializationFeature.FAIL_ON_SELF_REFERENCES, strict);
        mapper.configure(SerializationFeature.FAIL_ON_UNWRAPPED_TYPE_IDENTIFIERS, strict);
        mapper.configure(SerializationFeature.FAIL_ON_EMPTY_BEANS, strict);
        //.featuresToEnable(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES)
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, strict);
        mapper.configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, strict);
        return mapper;
    }
}
