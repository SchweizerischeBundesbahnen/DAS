package ch.sbb.playgroundbackend.controller;

import ch.sbb.playgroundbackend.model.azure.Action;
import ch.sbb.playgroundbackend.model.azure.Claims;
import ch.sbb.playgroundbackend.model.azure.TokenIssuanceStartRequest;
import ch.sbb.playgroundbackend.model.azure.TokenIssuanceStartResponse;
import ch.sbb.playgroundbackend.model.azure.TokenIssuanceStartResponseData;
import ch.sbb.playgroundbackend.service.SferaHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("customClaim")
public class CustomClaimController {

    private static final Logger log = LoggerFactory.getLogger(CustomClaimController.class);

    public CustomClaimController() {

    }

    @PostMapping
    TokenIssuanceStartResponse tokenIssuanceStartEvent(@RequestBody TokenIssuanceStartRequest body) {
        log.info("Received request with body: {}", body);


        Claims claims = new Claims("1085", "719_2024-06-13", "active");
        Action action = new Action("microsoft.graph.tokenIssuanceStart.provideClaimsForToken", claims);
        TokenIssuanceStartResponseData responseData = new TokenIssuanceStartResponseData("microsoft.graph.onTokenIssuanceStartResponseData", List.of(action));
        TokenIssuanceStartResponse response = new TokenIssuanceStartResponse(responseData);
        log.info("Response: {}", response);
        return response;
    }

}
