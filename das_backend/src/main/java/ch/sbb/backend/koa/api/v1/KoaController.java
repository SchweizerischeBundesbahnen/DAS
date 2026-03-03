package ch.sbb.backend.koa.api.v1;

import ch.sbb.backend.common.ApiDocumentation;
import ch.sbb.backend.koa.KoaClient;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = "KOA proxy")
public class KoaController {

    static final String PATH_SEGMENT_KOA = "/koa";
    static final String API_KOA = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_KOA;

    private final KoaClient koaClient;

    public KoaController(KoaClient koaClient) {
        this.koaClient = koaClient;
    }

    @PostMapping(API_KOA + "/subscribe")
    public ResponseEntity<?> subscribe(@RequestBody SubscribeRequest request) {
        return koaClient.subscribe(request);
    }

    @PostMapping(API_KOA + "/confirm/{messageId}/{deviceId}")
    public ResponseEntity<?> confirm(
        @PathVariable String messageId,
        @PathVariable String deviceId
    ) {
        return koaClient.confirm(messageId, deviceId);
    }

}
