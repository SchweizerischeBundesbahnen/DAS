package ch.sbb.backend.proxy;

import ch.sbb.backend.common.ApiDocumentation;
import ch.sbb.backend.common.ApiErrorResponses;
import ch.sbb.backend.common.ApiParametersDefault;
import ch.sbb.backend.common.ApiParametersDefault.ParamRequestId;
import ch.sbb.backend.common.Problem;
import ch.sbb.backend.common.ProxyClientException;
import ch.sbb.backend.common.ResponseEntityFactory;
import ch.sbb.backend.preload.application.TrainIdentificationService;
import ch.sbb.backend.proxy.model.request.CustomerOrientedDepartureSubscribe;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClientResponseException;

/**
 * de: KOA
 */
@RestController
@Tag(name = "CustomerOrientedDeparture", description = "Customer oriented departure proxy")
public class CustomerOrientedDepartureController {

    static final String PATH_SEGMENT_CUSTOMER_ORIENTED_DEPARTURE = "/customer-oriented-departure";
    static final String API_CUSTOMER_ORIENTED_DEPARTURE = ApiDocumentation.VERSION_URI_V1 + PATH_SEGMENT_CUSTOMER_ORIENTED_DEPARTURE;
    static final String API_CUSTOMER_ORIENTED_DEPARTURE_SUBSCRIBE = API_CUSTOMER_ORIENTED_DEPARTURE + "/subscribe";
    private static final String IR_13_COMPANY = "SBB";
    private static final String IR_13_LINE = "13";
    private static final String IR_13_VEHICLE_MODE = "IR";

    private final ProxyClient proxyClient;
    private final TrainIdentificationService trainIdentificationService;

    public CustomerOrientedDepartureController(ProxyClient proxyClient, TrainIdentificationService trainIdentificationService) {
        this.proxyClient = proxyClient;
        this.trainIdentificationService = trainIdentificationService;
    }

    // todo: validate requests on our side before calling downstream
    @PostMapping(API_CUSTOMER_ORIENTED_DEPARTURE_SUBSCRIBE)
    @ApiResponse(responseCode = "200", description = "OK")
    @ApiResponse(responseCode = "409", description = ApiDocumentation.STATUS_409,
        content = @Content(mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE, schema = @Schema(implementation = Problem.class)))
    @ApiResponse(responseCode = "502", description = ApiDocumentation.STATUS_502,
        content = @Content(mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE, schema = @Schema(implementation = Problem.class)))
    @ApiErrorResponses
    public ResponseEntity<?> subscribe(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @RequestBody CustomerOrientedDepartureSubscribe subscribe) {
        if (!isAllowedTrain(subscribe)) {
            return ResponseEntityFactory.createConflictResponse("Train not allowed", "Only trains of line " + IR_13_VEHICLE_MODE + IR_13_LINE + " are allowed.", requestId,
                API_CUSTOMER_ORIENTED_DEPARTURE_SUBSCRIBE);
        }
        try {
            return proxyClient.subscribe(ProxySubscribeRequest.from(subscribe, IR_13_COMPANY));
        } catch (RestClientResponseException ex) {
            throw new ProxyClientException(ex.getStatusCode(), ex.getResponseBodyAsString());
        }
    }

    private boolean isAllowedTrain(CustomerOrientedDepartureSubscribe subscribe) {
        return trainIdentificationService.isLineAndVehicleMode(subscribe.operationalTrainNumber(), subscribe.company(), subscribe.startDate(), IR_13_LINE, IR_13_VEHICLE_MODE);
    }

    @PostMapping(API_CUSTOMER_ORIENTED_DEPARTURE + "/confirm/{messageId}/{deviceId}")
    @ApiResponse(responseCode = "200", description = "OK")
    @ApiResponse(responseCode = "502", description = ApiDocumentation.STATUS_502,
        content = @Content(mediaType = MediaType.APPLICATION_PROBLEM_JSON_VALUE, schema = @Schema(implementation = Problem.class)))
    @ApiErrorResponses
    public ResponseEntity<?> confirm(
        @ParamRequestId @RequestHeader(value = ApiParametersDefault.HEADER_REQUEST_ID, required = false) String requestId,
        @PathVariable String messageId,
        @PathVariable String deviceId
    ) {
        try {
            return proxyClient.confirm(messageId, deviceId);
        } catch (RestClientResponseException ex) {
            throw new ProxyClientException(ex.getStatusCode(), ex.getResponseBodyAsString());
        }
    }

}
