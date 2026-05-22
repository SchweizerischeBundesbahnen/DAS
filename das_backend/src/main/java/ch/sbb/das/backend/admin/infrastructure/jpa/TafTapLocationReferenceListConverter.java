package ch.sbb.das.backend.admin.infrastructure.jpa;

import static java.util.Collections.emptyList;

import ch.sbb.das.backend.formation.domain.model.TafTapLocationReference;
import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.Arrays;
import java.util.List;

@Converter
public class TafTapLocationReferenceListConverter implements AttributeConverter<List<TafTapLocationReference>, String> {

    private static final String DELIMITER = ";";

    @Override
    public String convertToDatabaseColumn(List<TafTapLocationReference> references) {
        if (references == null || references.isEmpty()) {
            return null;
        }
        return references.stream().map(TafTapLocationReference::toLocationCode).distinct().sorted().reduce((a, b) -> a + DELIMITER + b).orElse(null);
    }

    @Override
    public List<TafTapLocationReference> convertToEntityAttribute(String value) {
        return value == null || value.isBlank()
            ? emptyList()
            : Arrays.stream(value.split(DELIMITER)).map(TafTapLocationReference::of).toList();
    }
}

