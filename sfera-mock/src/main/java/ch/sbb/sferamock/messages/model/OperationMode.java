package ch.sbb.sferamock.messages.model;

import java.util.List;

public record OperationMode(DrivingMode drivingMode,
                            Connectivity connectivity,
                            Architecture architecture) {

    public static OperationMode preloading = new OperationMode(DrivingMode.inactive, Connectivity.standalone, Architecture.boardCalculation);

    public static OperationMode observer = new OperationMode(DrivingMode.readOnly, Connectivity.connected, Architecture.boardCalculation);

    public static OperationMode driver = new OperationMode(DrivingMode.dasNotConnectedToAtp, Connectivity.connected, Architecture.boardCalculation);

    public static OperationMode preloadingGroundCalculation = new OperationMode(DrivingMode.inactive, Connectivity.standalone, Architecture.groundCalculation);

    public static OperationMode observerGroundCalculation = new OperationMode(DrivingMode.readOnly, Connectivity.connected, Architecture.groundCalculation);

    public static OperationMode driverGroundCalculation = new OperationMode(DrivingMode.dasNotConnectedToAtp, Connectivity.connected, Architecture.groundCalculation);

    public static List<OperationMode> validOperationModes = List.of(preloading, observer, driver);

    public static List<OperationMode> wrongArchitectureOperationModes = List.of(preloadingGroundCalculation, observerGroundCalculation, driverGroundCalculation);

    public boolean sendJourneyProfileUpdates() {
        return this.connectivity == Connectivity.connected && this.architecture == Architecture.boardCalculation;
    }

    public enum DrivingMode {dasNotConnectedToAtp, readOnly, inactive, other}

    public enum Connectivity {connected, standalone}

    public enum Architecture {boardCalculation, groundCalculation}
}
