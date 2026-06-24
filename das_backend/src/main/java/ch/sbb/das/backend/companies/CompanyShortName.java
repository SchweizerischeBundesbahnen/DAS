package ch.sbb.das.backend.companies;

import com.fasterxml.jackson.annotation.JsonValue;
import lombok.NonNull;

public record CompanyShortName(@JsonValue @NonNull String value) implements Comparable<CompanyShortName> {

    @Override
    public int compareTo(CompanyShortName other) {
        return this.value.compareTo(other.value);
    }
}

