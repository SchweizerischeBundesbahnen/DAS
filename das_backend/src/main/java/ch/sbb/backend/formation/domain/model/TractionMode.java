package ch.sbb.backend.formation.domain.model;

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

    public static TractionMode valueOfKey(String key) {
        for (TractionMode mode : TractionMode.values()) {
            if (mode.key.equals(key)) {
                return mode;
            }
        }
        throw new IllegalArgumentException("No TractionMode with key: " + key);
    }
}
