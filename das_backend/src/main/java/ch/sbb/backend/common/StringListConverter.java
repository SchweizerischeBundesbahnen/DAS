package ch.sbb.backend.common;

import static java.util.Collections.emptyList;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.Arrays;
import java.util.List;

@Converter
public class StringListConverter implements AttributeConverter<List<String>, String> {

    private static final String DELIMITER = ";";

    @Override
    public String convertToDatabaseColumn(List<String> stringList) {
        return stringList != null && !stringList.isEmpty() ? String.join(DELIMITER, stringList) : null;
    }

    @Override
    public List<String> convertToEntityAttribute(String string) {
        return string != null ? Arrays.asList(string.split(DELIMITER)) : emptyList();
    }
}
