package ch.sbb.sferamock.exchange.model;

public record TokenIssuanceStartRequest(String type, String source, TokenIssuanceStartRequestData data) {
}
