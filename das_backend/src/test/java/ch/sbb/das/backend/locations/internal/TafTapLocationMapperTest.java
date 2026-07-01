package ch.sbb.das.backend.locations.internal;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.das.backend.common.DateTimeUtil;
import java.time.LocalDate;
import org.junit.jupiter.api.Test;

class TafTapLocationMapperTest {

    private final TafTapLocationMapper mapper = new TafTapLocationMapper();

    @Test
    void toEntityFromServicePoint_maps_uic_country_code_to_location_reference() {
        ServicePoint sp = new ServicePoint(
            "Bern",
            "BN",
            LocalDate.of(2026, 1, 1),
            LocalDate.of(2027, 1, 1),
            new ServicePoint.ServicePointNumber(7000, 85)
        );

        TafTapLocationEntity entity = mapper.toEntityFromServicePoint(sp);

        assertThat(entity.getId()).isNull();
        assertThat(entity.getLocationReference()).isEqualTo("CH07000");
        assertThat(entity.getPrimaryLocationName()).isEqualTo("Bern");
        assertThat(entity.getLocationAbbreviation()).isEqualTo("BN");
        assertThat(entity.getValidFrom()).isEqualTo(LocalDate.of(2026, 1, 1));
        assertThat(entity.getValidTo()).isEqualTo(LocalDate.of(2027, 1, 1));
    }

    @Test
    void toResponse_returns_future_valid_from_only() {
        LocalDate today = DateTimeUtil.today();

        TafTapLocationEntity futureEntity = new TafTapLocationEntity(
            1,
            "CH07000",
            "Bern",
            "BN",
            today.plusDays(1),
            null
        );

        TafTapLocationEntity currentEntity = new TafTapLocationEntity(
            2,
            "CH08000",
            "Zurich",
            "ZH",
            today,
            null
        );

        TafTapLocation futureResponse = mapper.toResponse(futureEntity);
        TafTapLocation currentResponse = mapper.toResponse(currentEntity);

        assertThat(futureResponse.validFrom()).isEqualTo(today.plusDays(1));
        assertThat(currentResponse.validFrom()).isNull();
    }
}

