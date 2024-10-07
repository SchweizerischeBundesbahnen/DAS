package ch.sbb.sferamock.exchange.model;

public record TokenIssuanceStartRequestData(String tenantId, String authenticationEventListenerId,
                                            String customAuthenticationExtensionId,
                                            AuthenticationContext authenticationContext) {
}
