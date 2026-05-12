package ch.sbb.das.backend.common;

import static java.util.Collections.emptyList;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

@Converter
public class CompanyCodeListConverter implements AttributeConverter<List<CompanyCode>, String> {

    private static final String DELIMITER = ";";

    @Override
    public String convertToDatabaseColumn(List<CompanyCode> companyCodeList) {
        if (companyCodeList == null || companyCodeList.isEmpty()) {
            return null;
        }
        return companyCodeList.stream().map(CompanyCode::value).collect(Collectors.joining(DELIMITER));
    }

    @Override
    public List<CompanyCode> convertToEntityAttribute(String string) {
        return string != null ? Arrays.stream(string.split(DELIMITER)).map(CompanyCode::new).toList() : emptyList();
    }
}
