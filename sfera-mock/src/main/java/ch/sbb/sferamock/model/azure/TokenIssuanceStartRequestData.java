package ch.sbb.sferamock.model.azure;

public record TokenIssuanceStartRequestData(String tenantId, String authenticationEventListenerId,
                                            String customAuthenticationExtensionId,
                                            AuthenticationContext authenticationContext) {
}
