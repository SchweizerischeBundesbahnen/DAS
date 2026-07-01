package ch.sbb.das.backend.companies.internal;

import ch.sbb.das.backend.companies.CompanyCode;
import org.jspecify.annotations.NonNull;
import org.springframework.boot.context.properties.ConfigurationPropertiesBinding;
import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;

/**
 * Configuration binding converters for the {@link CompanyCode} tiny type.
 *
 * <p>Allows Spring Boot to map configured company code values (string or integer)
 * into validated {@link CompanyCode} instances.
 */
class CompanyCodeConverter {

    private CompanyCodeConverter() {
        /* This utility class should not be instantiated */
    }

    @Component
    @ConfigurationPropertiesBinding
    public static class FromString implements Converter<String, CompanyCode> {

        @Override
        public CompanyCode convert(@NonNull String source) {
            return new CompanyCode(source);
        }
    }

    @Component
    @ConfigurationPropertiesBinding
    public static class FromInteger implements Converter<Integer, CompanyCode> {

        @Override
        public CompanyCode convert(Integer source) {
            return new CompanyCode(source.toString());
        }
    }
}
