package ch.sbb.das.backend.admin.application.ruindications.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.media.Schema.AccessMode;
import io.swagger.v3.oas.annotations.media.Schema.RequiredMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.util.CollectionUtils;

public record RuIndication(
    @Schema(description = "The unique identifier of the RU indication.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    Integer id,
    @Schema(description = "Title and text content of the RU indication.", requiredMode = RequiredMode.REQUIRED)
    RuIndicationContent content,
    @Schema(description = "Scope of the RU indication.", requiredMode = RequiredMode.REQUIRED)
    RuIndicationScope scope,
    @Schema(description = "Valid periods of the RU indication.", requiredMode = RequiredMode.REQUIRED)
    List<RuIndicationPeriod> periods,
    @Schema(description = "The timestamp of the last update to the RU indication entry.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    LocalDateTime lastModifiedAt,
    @Schema(description = "The user who created or last updated the RU indication.", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    String lastModifiedBy
) {

    public RuIndication(Integer id, RuIndicationContent content, RuIndicationScope scope, List<RuIndicationPeriod> periods) {
        this(id, content, scope, periods, null, null);
    }

    @JsonProperty
    @Schema(description = "Status of RU indication", requiredMode = RequiredMode.REQUIRED, accessMode = AccessMode.READ_ONLY)
    public PeriodStatus status() {
        if (CollectionUtils.isEmpty(periods)) {
            return PeriodStatus.ACTIVE;
        }
        LocalDate today = LocalDate.now();
        if (periods.stream().anyMatch(period -> period.status(today) == PeriodStatus.ACTIVE)) {
            return PeriodStatus.ACTIVE;
        }
        if (periods.stream().allMatch(period -> period.status(today) == PeriodStatus.EXPIRED)) {
            return PeriodStatus.EXPIRED;
        }
        return PeriodStatus.INACTIVE;
    }
}

