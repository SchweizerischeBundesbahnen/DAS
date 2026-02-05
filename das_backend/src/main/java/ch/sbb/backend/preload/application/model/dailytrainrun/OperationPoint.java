package ch.sbb.backend.preload.application.model.dailytrainrun;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.NonNull;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
public class OperationPoint {

    @NonNull
    String abbreviation;

    @NonNull
    Integer uicCode;

    @NonNull
    Integer countryCode;
}
