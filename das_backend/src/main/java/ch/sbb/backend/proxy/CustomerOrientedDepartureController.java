package ch.sbb.backend.proxy;

import ch.sbb.backend.common.ApiDocumentation;
import ch.sbb.backend.proxy.model.request.SubscribeRequest;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

/**
 * de: KOA
 */
@RestController
@Tag(name = "CustomerOrientedDeparture", description = "Customer oriented departure proxy")
public class CustomerOrientedDepartureController {

    static final String PATH_SEGMENT_CUSTOMER_ORIENTED_DEPARTURE = "/customer-oriented-departure";
    static final String API_CUSTOMER_ORIENTED_DEPARTURE = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_CUSTOMER_ORIENTED_DEPARTURE;

    private final ProxyClient proxyClient;

    public CustomerOrientedDepartureController(ProxyClient proxyClient) {
        this.proxyClient = proxyClient;
    }

    @PostMapping(API_CUSTOMER_ORIENTED_DEPARTURE + "/subscribe")
    public ResponseEntity<?> subscribe(@RequestBody SubscribeRequest request) {
        return proxyClient.subscribe(request);
    }

    @PostMapping(API_CUSTOMER_ORIENTED_DEPARTURE + "/confirm/{messageId}/{deviceId}")
    public ResponseEntity<?> confirm(
        @PathVariable String messageId,
        @PathVariable String deviceId
    ) {
        return proxyClient.confirm(messageId, deviceId);
    }

}
