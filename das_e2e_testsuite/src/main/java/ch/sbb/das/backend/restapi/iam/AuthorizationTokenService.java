package ch.sbb.das.backend.restapi.iam;

import lombok.NonNull;
import org.springframework.web.reactive.function.client.ClientRequest;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

/**
 * Provides {@link org.springframework.http.HttpHeaders#AUTHORIZATION} tokens for requests.
 */
public interface AuthorizationTokenService {

    /**
     * Retrieve the authorization token for the given request. Emits new token after {@link #renewToken(ClientRequest)} is called.
     *
     * @param request
     * @return A {@link Flux} stream which emits the token.
     */
    @NonNull
    Flux<String> token(@NonNull ClientRequest request);

    /**
     * Renew the token for the given request
     *
     * @param request
     * @return A {@link Mono} stream which emits the new token.
     */
    @NonNull
    Mono<String> renewToken(@NonNull ClientRequest request);
}
