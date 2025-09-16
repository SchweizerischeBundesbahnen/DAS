package ch.sbb.backend.formation.domain.model;

public class UnexpectedProviderData extends IllegalStateException {

    public UnexpectedProviderData(String message) {
        super(message);
    }
}
