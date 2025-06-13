package ch.sbb.backend.formation.infrastructure.trainformation.model;

public enum TractionMode {
    ZUGLOK("STAMMLOK"),
    DOPPELTRAKTION("D"),
    SCHIEBELOK("P"),
    UEBERFUEHRUNG("Q"),
    SCHLEPPLOK("S"),
    VORSPANN("V"),
    ZWISCHENLOK("Z");

    private final String key;

    TractionMode(String key) {
        this.key = key;
    }
}
