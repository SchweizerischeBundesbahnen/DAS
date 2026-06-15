package ch.sbb.das.backend.companies;

public record Company(
    CompanyCode code,
    CompanyShortName shortName
) {

    public Company(String code, String shortName) {
        this(new CompanyCode(code), new CompanyShortName(shortName));
    }
}
