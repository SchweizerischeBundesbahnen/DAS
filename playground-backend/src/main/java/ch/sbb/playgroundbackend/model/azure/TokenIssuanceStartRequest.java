package ch.sbb.playgroundbackend.model.azure;

public record TokenIssuanceStartRequest(String type, String source, TokenIssuanceStartRequestData data) {
}
