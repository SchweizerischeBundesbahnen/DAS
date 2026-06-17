package ch.sbb.das.backend.admin.application.common;

public interface TranslatedContentRequest<T> {

    Object de();

    Object fr();

    Object it();

    T normalize(T content);
}
