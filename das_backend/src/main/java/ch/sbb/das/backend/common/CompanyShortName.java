package ch.sbb.das.backend.common;

import lombok.NonNull;
import lombok.Value;

@Value(staticConstructor = "of")
public class CompanyShortName {

    @NonNull
    String value;
}

