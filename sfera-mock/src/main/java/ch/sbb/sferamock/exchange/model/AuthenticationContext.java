package ch.sbb.sferamock.exchange.model;

public record AuthenticationContext(String correlationId, AuthenticationClient client, String protocol,
                                    ServicePrinciple clientServicePrincipal, ServicePrinciple resourceServicePrincipal,
                                    AzureUser user) {
}
