package ch.sbb.das.backend.companies;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter(autoApply = true)
public class CompanyCodeConverter implements AttributeConverter<CompanyCode, String> {

    @Override
    public String convertToDatabaseColumn(CompanyCode companyCode) {
        return companyCode != null ? companyCode.value() : null;
    }

    @Override
    public CompanyCode convertToEntityAttribute(String value) {
        return value != null ? new CompanyCode(value) : null;
    }
}
