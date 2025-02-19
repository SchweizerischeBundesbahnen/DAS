package ch.sbb.sferamock.messages.common;

public enum SferaErrorCodes {

    SFERA_XSD_VERSION_NOT_SUPPORTED("2"),
    INTENDED_RECIPIENT_NOT_ACTUAL_RECIPIENT("7"),
    XML_SCHEMA_VIOLATION("13"),
    ACTION_NOT_AUTHORIZED_FOR_USER("46"),
    DATA_TEMPORARILY_UNAVAILABLE("48"),
    COULD_NOT_PROCESS_DATA("50"),
    INCONSISTENT_DATA("53");

    final String code;

    SferaErrorCodes(String code) {
        this.code = code;
    }

    public String getCode() {
        return code;
    }

}
