package ch.sbb.das.backend.indications.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.ScheduleType;
import ch.sbb.das.backend.indications.internal.model.SpecialHoliday;
import ch.sbb.das.backend.indications.internal.model.SpecialHolidayRequest;
import java.time.LocalDate;
import java.util.Set;
import org.junit.jupiter.api.Test;

class SpecialHolidayMapperTest {

    private final SpecialHolidayMapper mapper = new SpecialHolidayMapper();

    private static CompanyCode company(String value) {
        return new CompanyCode(value);
    }

    @Test
    void toResponse_maps_all_fields() {
        SpecialHolidayEntity entity = new SpecialHolidayEntity();
        entity.setId(5);
        entity.setName("Auffahrt");
        entity.setDate(LocalDate.of(2026, 5, 14));
        entity.setScheduleType(ScheduleType.SUNDAY_SCHEDULE);
        entity.setCompanies(Set.of(company("1111"), company("2222")));

        SpecialHoliday response = mapper.toResponse(entity);

        assertThat(response.id()).isEqualTo(5);
        assertThat(response.name()).isEqualTo("Auffahrt");
        assertThat(response.date()).isEqualTo(LocalDate.of(2026, 5, 14));
        assertThat(response.scheduleType()).isEqualTo(ScheduleType.SUNDAY_SCHEDULE);
        assertThat(response.companies()).containsExactlyInAnyOrder(company("1111"), company("2222"));
    }

    @Test
    void toEntityFromRequest_sets_id_and_maps_payload() {
        SpecialHolidayRequest request = new SpecialHolidayRequest(
            "Pfingstmontag",
            LocalDate.of(2026, 5, 25),
            ScheduleType.MONDAY_SCHEDULE,
            Set.of(company("1111"))
        );

        SpecialHolidayEntity entity = mapper.toEntityFromRequest(10, request);

        assertThat(entity.getId()).isEqualTo(10);
        assertThat(entity.getName()).isEqualTo("Pfingstmontag");
        assertThat(entity.getDate()).isEqualTo(LocalDate.of(2026, 5, 25));
        assertThat(entity.getScheduleType()).isEqualTo(ScheduleType.MONDAY_SCHEDULE);
        assertThat(entity.getCompanies()).containsExactly(company("1111"));
    }

    @Test
    void updateEntityFromRequest_overwrites_entity_fields() {
        SpecialHolidayEntity entity = new SpecialHolidayEntity();
        entity.setName("Old");
        entity.setDate(LocalDate.of(2026, 1, 1));
        entity.setScheduleType(ScheduleType.SUNDAY_SCHEDULE);

        SpecialHolidayRequest request = new SpecialHolidayRequest(
            "New Name",
            LocalDate.of(2026, 12, 31),
            ScheduleType.MONDAY_SCHEDULE,
            Set.of(company("2222"))
        );

        mapper.updateEntityFromRequest(entity, request);

        assertThat(entity.getName()).isEqualTo("New Name");
        assertThat(entity.getDate()).isEqualTo(LocalDate.of(2026, 12, 31));
        assertThat(entity.getScheduleType()).isEqualTo(ScheduleType.MONDAY_SCHEDULE);
        assertThat(entity.getCompanies()).containsExactly(company("2222"));
    }
}

