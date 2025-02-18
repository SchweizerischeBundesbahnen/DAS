package ch.sbb.sferamock.messages.sfera;

import ch.sbb.sferamock.adapters.sfera.model.v0201.DASModesComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0201.ReportedDASDrivingMode;
import ch.sbb.sferamock.adapters.sfera.model.v0201.UnavailableDASOperatingModes;
import ch.sbb.sferamock.messages.model.OperationMode;
import java.util.List;

public final class SferaToInternalConverters {

    private SferaToInternalConverters() {
    }

    public static List<OperationMode> convertOperationModes(List<DASModesComplexType> dasOperatingModesSupported) {
        return dasOperatingModesSupported.stream()
            .map(SferaToInternalConverters::convertOperationMode)
            .toList();
    }

    private static OperationMode convertOperationMode(DASModesComplexType dasModesComplexType) {
        return new OperationMode(
            convertDrivingMode(dasModesComplexType.getDASDrivingMode()),
            convertConnectivity(dasModesComplexType.getDASConnectivity()),
            convertArchitecture(dasModesComplexType.getDASArchitecture())
        );
    }

    private static OperationMode.Architecture convertArchitecture(UnavailableDASOperatingModes.DASArchitecture dasArchitecture) {
        return switch (dasArchitecture) {
            case BOARD_ADVICE_CALCULATION -> OperationMode.Architecture.boardCalculation;
            case GROUND_ADVICE_CALCULATION -> OperationMode.Architecture.groundCalculation;
        };
    }

    private static OperationMode.Connectivity convertConnectivity(UnavailableDASOperatingModes.DASConnectivity dasConnectivity) {
        return switch (dasConnectivity) {
            case CONNECTED -> OperationMode.Connectivity.connected;
            case STANDALONE -> OperationMode.Connectivity.standalone;
        };
    }

    private static OperationMode.DrivingMode convertDrivingMode(ReportedDASDrivingMode.DASDrivingMode dasDrivingMode) {
        return switch (dasDrivingMode) {
            case READ_ONLY -> OperationMode.DrivingMode.readOnly;
            case DAS_NOT_CONNECTED_TO_ATP -> OperationMode.DrivingMode.dasNotConnectedToAtp;
            case INACTIVE -> OperationMode.DrivingMode.inactive;
            default -> OperationMode.DrivingMode.other;
        };
    }
}
