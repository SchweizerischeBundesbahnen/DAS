package ch.sbb.backend.admin.domain.servicepoint.model;

public record ServicePoint(
    Integer uic,
    String designation,
    String abbreviation
) {

}
