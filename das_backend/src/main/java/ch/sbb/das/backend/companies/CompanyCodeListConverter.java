package ch.sbb.das.backend.companies;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;
import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;
import org.springframework.util.CollectionUtils;

@Converter
public class CompanyCodeListConverter implements AttributeConverter<Set<CompanyCode>, String> {

    private static final String DELIMITER = ";";

    @Override
    public String convertToDatabaseColumn(Set<CompanyCode> companyCodeList) {
        if (CollectionUtils.isEmpty(companyCodeList)) {
            return null;
        }
        return companyCodeList.stream().map(CompanyCode::value).collect(Collectors.joining(DELIMITER));
    }

    @Override
    public Set<CompanyCode> convertToEntityAttribute(String string) {
        return string != null ? Arrays.stream(string.split(DELIMITER)).map(CompanyCode::new).collect(Collectors.toSet()) : Set.of();
    }
}
