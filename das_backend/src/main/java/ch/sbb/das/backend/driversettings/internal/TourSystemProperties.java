package ch.sbb.das.backend.driversettings.internal;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "tour-systems")
record TourSystemProperties(Map<String, TourSystemEntry> entries) {

    TourSystemProperties {
        if (entries == null) {
            entries = new LinkedHashMap<>();
        }
    }

    List<TourSystem> toTourSystems() {
        return entries.entrySet().stream()
            .map(entry -> new TourSystem(entry.getKey(), entry.getValue().label(), entry.getValue().url()))
            .toList();
    }

    record TourSystemEntry(String label, String url) {
    }
}
