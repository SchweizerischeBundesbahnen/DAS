package ch.sbb.sferamock.model.azure;

public record AuthenticationContext(String correlationId, AuthenticationClient client, String protocol,
                                    ServicePrinciple clientServicePrincipal, ServicePrinciple resourceServicePrincipal,
                                    AzureUser user) {
}
