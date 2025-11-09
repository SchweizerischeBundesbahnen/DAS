package ch.sbb.das.backend.restapi.iam.ssoutils;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;
import org.jetbrains.annotations.NotNull;
import org.reactivestreams.Publisher;
import org.springframework.core.ResolvableType;
import org.springframework.core.codec.CodecException;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.MediaType;
import org.springframework.http.codec.json.AbstractJackson2Decoder;
import org.springframework.lang.Nullable;
import org.springframework.util.MimeType;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Decode/map a successful JSON-response from a preceeding HTTP-request for real asynchroneous callers.
 *
 * @author Lukas Spirig
 * @see <a href="https://kalpads.medium.com/error-handling-with-reactive-streams-77b6ec7231ff">error-handling with reactive streams</a>
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
@Slf4j
class JsonResponseDecoder extends AbstractJackson2Decoder {

    JsonResponseDecoder(ObjectMapper mapper) {
        super(mapper, MediaType.APPLICATION_JSON);
    }

    @Override
    public @NotNull Flux<Object> decode(
        @NotNull Publisher<DataBuffer> input,
        @NotNull ResolvableType elementType,
        @Nullable MimeType mimeType,
        @Nullable Map<String, Object> hints) {
        return super.decode(input, elementType, mimeType, hints)
            .onErrorMap(e -> wrapException(elementType, e));
    }

    /**
     * This is not involved by {@link } !
     *
     * @param input
     * @param elementType
     * @param mimeType
     * @param hints
     * @return JSON decoded Mono or wrapped model-exception if deserialization failed.
     */
    @Override
    public @NotNull Mono<Object> decodeToMono(
        @NotNull Publisher<DataBuffer> input,
        @NotNull ResolvableType elementType,
        @Nullable MimeType mimeType,
        @Nullable Map<String, Object> hints) {
        return super.decode(input, elementType, mimeType, hints)
            // if not mapped DecodingException (cause: JsonMappingException) results otherwise
            .onErrorMap(e -> wrapException(elementType, e))
            .singleOrEmpty();
    }

    private Throwable wrapException(ResolvableType elementType, Throwable throwable) {
        if (throwable instanceof CodecException) {
            String message = String.format("REST-API JSON to raw Model (POJO): %s", elementType);
            return new RequesterMappingException(message, throwable);
        } else {
            // should not happen
            log.warn("Unexpected exception remains unwrapped: {}", elementType, throwable);
            return throwable;
        }
    }
}
