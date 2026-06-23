package ch.sbb.das.backend.common;

public interface TranslatedContentRequest<T> {

    Object de();

    Object fr();

    Object it();

    T normalize(T content);
}
