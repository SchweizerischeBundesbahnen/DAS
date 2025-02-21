package ch.sbb.sferamock.messages.model;

import java.time.LocalDate;
import java.util.Optional;
import java.util.regex.Pattern;
import lombok.NonNull;

public record TrainIdentification(@NonNull CompanyCode companyCode, @NonNull String operationalNumber, @NonNull LocalDate date, @NonNull Optional<String> additionalNumber) {

    private static final Pattern TID_PATTERN = Pattern.compile("([^_]+)_([0-9-]+)(?:_(.+))?");

    public TrainIdentification(@NonNull CompanyCode companyCode, @NonNull String operationalNumber, @NonNull LocalDate date) {
        this(companyCode, operationalNumber, date, Optional.empty());
    }

    public static TrainIdentification fromString(String tid, String companyCode) {
        var matcher = TID_PATTERN.matcher(tid);
        if (matcher.matches()) {
            var operationalNumber = matcher.group(1);
            var additionalNumber = matcher.group(3) == null ? null : matcher.group(3);
            var date = matcher.group(2);
            return new TrainIdentification(new CompanyCode(companyCode), operationalNumber, LocalDate.parse(date), Optional.ofNullable(additionalNumber));
        }
        throw new IllegalArgumentException("Illegal train id string: " + tid);
    }

    public boolean isManualLocation() {
        return operationalNumber.substring(operationalNumber.length() - 1).equalsIgnoreCase("M");
    }

    public String baseOperationalNumber() {
        if (isManualLocation()) {
            return operationalNumber.substring(0, operationalNumber.length() - 1);
        }
        return operationalNumber;
    }
}
