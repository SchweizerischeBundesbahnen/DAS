package ch.sbb.sferamock.model.azure;

public record TokenIssuanceStartRequest(String type, String source, TokenIssuanceStartRequestData data) {
}
