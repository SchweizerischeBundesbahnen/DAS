package ch.sbb.das.backend.preload.application.model.trainidentification;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.NonNull;

@Builder
@AllArgsConstructor
@NoArgsConstructor
@Getter
public class TrainRunPoint {

    @NonNull
    Integer countryCodeUic;

    Integer departureTimeOperational;

    Integer departureTimeCommercial;
}
