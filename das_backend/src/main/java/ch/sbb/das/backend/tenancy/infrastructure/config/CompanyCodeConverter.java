package ch.sbb.das.backend.tenancy.infrastructure.config;

import ch.sbb.das.backend.common.CompanyCode;
import org.jspecify.annotations.NonNull;
import org.springframework.boot.context.properties.ConfigurationPropertiesBinding;
import org.springframework.core.convert.converter.Converter;
import org.springframework.stereotype.Component;

public class CompanyCodeConverter {

    private CompanyCodeConverter() {
        /* This utility class should not be instantiated */
    }

    @Component
    @ConfigurationPropertiesBinding
    public static class FromString implements Converter<String, CompanyCode> {

        @Override
        public CompanyCode convert(@NonNull String source) {
            return CompanyCode.of(source);
        }
    }

    @Component
    @ConfigurationPropertiesBinding
    public static class FromInteger implements Converter<Integer, CompanyCode> {

        @Override
        public CompanyCode convert(Integer source) {
            return CompanyCode.of(source.toString());
        }
    }
}
