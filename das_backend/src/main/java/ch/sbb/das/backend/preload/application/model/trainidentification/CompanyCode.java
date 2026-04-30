package ch.sbb.das.backend.preload.application.model.trainidentification;

import lombok.NonNull;
import lombok.Value;

@Value(staticConstructor = "of")
public class CompanyCode {

    @NonNull
    String value;

}
