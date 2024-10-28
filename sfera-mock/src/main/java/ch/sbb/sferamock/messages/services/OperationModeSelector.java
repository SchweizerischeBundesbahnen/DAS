package ch.sbb.sferamock.messages.services;

import static ch.sbb.sferamock.messages.model.OperationMode.driver;
import static ch.sbb.sferamock.messages.model.OperationMode.observer;
import static ch.sbb.sferamock.messages.model.OperationMode.preloading;
import static ch.sbb.sferamock.messages.model.OperationMode.validOperationModes;
import static ch.sbb.sferamock.messages.model.OperationMode.wrongArchitectureOperationModes;

import ch.sbb.sferamock.messages.model.OperationMode;
import java.util.List;
import java.util.Optional;
import org.springframework.stereotype.Service;

@Service
public class OperationModeSelector {

    private static Optional<OperationMode> getObserver(boolean validReporting) {
        return validReporting
            ? Optional.of(observer)
            : Optional.empty();
    }

    public Optional<OperationMode> selectOperationMode(List<OperationMode> incomingOperationModes, boolean statusReportEnabled) {

        var validModes = incomingOperationModes.stream()
            .filter(validOperationModes::contains)
            .toList();

        if (validModes.contains(driver) && validModes.contains(observer)) {
            return getObserver(statusReportEnabled);
        }
        if (validModes.contains(driver)) {
            return Optional.empty();
        }
        if (validModes.contains(observer)) {
            return getObserver(!statusReportEnabled);
        }
        if (validModes.contains(preloading)) {
            return Optional.of(preloading);
        }
        return Optional.empty();
    }

    public boolean hasWrongArchitecture(List<OperationMode> incomingOperationModes) {
        return incomingOperationModes.stream()
            .anyMatch(wrongArchitectureOperationModes::contains);
    }
}
