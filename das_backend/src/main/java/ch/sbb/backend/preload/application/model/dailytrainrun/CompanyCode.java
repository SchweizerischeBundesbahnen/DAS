package ch.sbb.backend.preload.application.model.dailytrainrun;

import lombok.NonNull;
import lombok.Value;

@Value(staticConstructor = "of")
public class CompanyCode {

    @NonNull
    String value;

}
