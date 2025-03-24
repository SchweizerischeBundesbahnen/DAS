package ch.sbb.backend.admin.infrastructure.entities;

import ch.sbb.backend.admin.domain.ServicePoint;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;

@Entity(name = "service_point")
public class ServicePointEntity {

    @Id
    Integer uic;

    String designation;

    String abbreviation;

    public ServicePointEntity(ServicePoint sp) {
        this.uic = sp.uic();
        this.designation = sp.designation();
        this.abbreviation = sp.abbreviation();
    }

    public ServicePointEntity() {
        
    }

    public ServicePoint toServicePoint() {
        return new ServicePoint(uic, designation, abbreviation);
    }

}
