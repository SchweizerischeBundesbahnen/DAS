package ch.sbb.backend.formation.infrastructure.trainformation.model;

import jakarta.persistence.Embeddable;
import lombok.Getter;
import lombok.Setter;

// todo could also be one consolidated String
@Getter
@Setter
@Embeddable
public class TafTapLocationReference {

    private String teltsiCountryCodeIso;
    private Integer teltsiLocationPrimaryCode;
}
