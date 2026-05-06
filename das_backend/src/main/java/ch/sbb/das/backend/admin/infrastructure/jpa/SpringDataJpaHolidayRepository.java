package ch.sbb.das.backend.admin.infrastructure.jpa;

import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SpringDataJpaHolidayRepository extends ListCrudRepository<HolidayEntity, Integer> {

}

