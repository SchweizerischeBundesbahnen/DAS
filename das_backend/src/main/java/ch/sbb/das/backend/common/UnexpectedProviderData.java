package ch.sbb.das.backend.common;

public class UnexpectedProviderData extends IllegalStateException {

    public UnexpectedProviderData(String message) {
        super(message);
    }
}
