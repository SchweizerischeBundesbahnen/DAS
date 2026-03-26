package ch.sbb.backend.admin.infrastructure.locations;

import ch.sbb.backend.admin.domain.locations.Location;
import ch.sbb.backend.formation.domain.model.TafTapLocationReference;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import java.time.LocalDate;
import lombok.NoArgsConstructor;

@Table(name = "location")
@Entity
@NoArgsConstructor
public class LocationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "location_id_seq")
    @SequenceGenerator(name = "location_id_seq", allocationSize = 1)
    private Integer id;

    private String locationReference;
    private String primaryLocationName;
    private String locationAbbreviation;
    private LocalDate validFrom;
    private LocalDate validTo;

    public static LocationEntity from(Location location) {
        LocationEntity entity = new LocationEntity();
        entity.locationReference = location.locationReference().toLocationCode();
        entity.primaryLocationName = location.primaryLocationName();
        entity.locationAbbreviation = location.locationAbbreviation();
        entity.validFrom = location.validFrom();
        entity.validTo = location.validTo();
        return entity;
    }

    public Location toLocation() {
        return new Location(locationReference(), primaryLocationName, locationAbbreviation, validFrom, validTo);
    }

    public TafTapLocationReference locationReference() {
        return new TafTapLocationReference(locationReference.substring(0, 2), Integer.valueOf(locationReference.substring(2)));
    }
}
