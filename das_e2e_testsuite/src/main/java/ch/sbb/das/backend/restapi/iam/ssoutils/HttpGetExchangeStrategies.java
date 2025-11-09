package ch.sbb.das.backend.restapi.iam.ssoutils;

import ch.sbb.das.backend.restapi.helper.ObjectMapperFactory;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import org.jetbrains.annotations.NotNull;
import org.springframework.http.MediaType;
import org.springframework.http.codec.HttpMessageReader;
import org.springframework.http.codec.HttpMessageWriter;
import org.springframework.http.codec.json.Jackson2JsonEncoder;
import org.springframework.web.reactive.function.client.ExchangeStrategies;

/**
 * WebClient strategies
 *
 * @author Lukas Spirig
 * @deprecated use a simpler OAuth2 Token GET approach
 */
@Deprecated
public class HttpGetExchangeStrategies implements ExchangeStrategies {

    private static final Integer DEFAULT_MAX_IN_MEMORY_SIZE = 16 * 1024 * 1024; // 16MB (locally tested. currently sufficient. 2021-09-13)

    private final List<HttpMessageReader<?>> messageReaders;
    private final List<HttpMessageWriter<?>> messageWriters;

    public HttpGetExchangeStrategies(boolean strict) {
        this(strict, DEFAULT_MAX_IN_MEMORY_SIZE);
    }

    /**
     * @param strict ObjectMapper strict JSON deserialization
     * @param maxInMemorySize exceeded limit on max bytes to buffer for e.g. 16*1024*1024 (16MB) (increase for webflux error in spring-boot-starter-webflux context)
     */
    public HttpGetExchangeStrategies(boolean strict, Integer maxInMemorySize) {
        final ObjectMapper mapper = ObjectMapperFactory.createMapper(strict);
        ExchangeStrategies exchangeStrategies = ExchangeStrategies.builder()
            .codecs(configurer -> {
                configurer
                    .defaultCodecs()
                    .jackson2JsonEncoder(
                        // standard Spring
                        new Jackson2JsonEncoder(mapper, MediaType.APPLICATION_JSON));
                configurer
                    .defaultCodecs()
                    .jackson2JsonDecoder(new JsonResponseDecoder(mapper));
                if (maxInMemorySize != null) {
                    configurer.defaultCodecs()
                        .maxInMemorySize(maxInMemorySize);
                }
            })
            .build();
        messageReaders = exchangeStrategies.messageReaders();
        messageWriters = exchangeStrategies.messageWriters();
    }

    @Override
    public @NotNull List<HttpMessageReader<?>> messageReaders() {
        return messageReaders;
    }

    @Override
    public @NotNull List<HttpMessageWriter<?>> messageWriters() {
        return messageWriters;
    }
}
