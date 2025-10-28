package ch.sbb.sferamock;

import static ch.sbb.sferamock.IntegrationTestData.IM_COMPANY_CODE_SBB_INFRA;
import static ch.sbb.sferamock.IntegrationTestData.RU_COMPANY_CODE_SBB_AG;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.ReportedDASDrivingMode.DASDrivingMode.DAS_NOT_CONNECTED_TO_ATP;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.ReportedDASDrivingMode.DASDrivingMode.INACTIVE;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.ReportedDASDrivingMode.DASDrivingMode.READ_ONLY;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.UnavailableDASOperatingModes.DASArchitecture.BOARD_ADVICE_CALCULATION;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.UnavailableDASOperatingModes.DASArchitecture.GROUND_ADVICE_CALCULATION;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.UnavailableDASOperatingModes.DASConnectivity.CONNECTED;
import static ch.sbb.sferamock.adapters.sfera.model.v0300.UnavailableDASOperatingModes.DASConnectivity.STANDALONE;

import ch.sbb.sferamock.adapters.sfera.model.v0300.B2GRequest;
import ch.sbb.sferamock.adapters.sfera.model.v0300.DASModesComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0300.HandshakeRequest;
import ch.sbb.sferamock.adapters.sfera.model.v0300.JPRequest;
import ch.sbb.sferamock.adapters.sfera.model.v0300.MessageHeader;
import ch.sbb.sferamock.adapters.sfera.model.v0300.OTNIDComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0300.Recipient;
import ch.sbb.sferamock.adapters.sfera.model.v0300.ReportedDASDrivingMode;
import ch.sbb.sferamock.adapters.sfera.model.v0300.SFERAB2GRequestMessage;
import ch.sbb.sferamock.adapters.sfera.model.v0300.SPRequest;
import ch.sbb.sferamock.adapters.sfera.model.v0300.SPZoneComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0300.Sender;
import ch.sbb.sferamock.adapters.sfera.model.v0300.TrainIdentificationComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0300.UnavailableDASOperatingModes;
import ch.sbb.sferamock.messages.common.XmlDateHelper;
import ch.sbb.sferamock.messages.model.CompanyCode;
import java.time.LocalDate;
import java.time.ZonedDateTime;
import java.util.UUID;
import lombok.experimental.UtilityClass;
import lombok.val;

@UtilityClass
class SferaIntegrationTestData {

    static final String SFERA_VERSION = "3.00";
    static final String SOURCE_DEVICE = "DAS";

    static final DASModesComplexType READONLY_CONNECTED_BOARDCALCULATION = createDASModes(READ_ONLY, CONNECTED, BOARD_ADVICE_CALCULATION);
    static final DASModesComplexType DRIVER_CONNECTED_BOARDCALCULATION = createDASModes(DAS_NOT_CONNECTED_TO_ATP, CONNECTED, BOARD_ADVICE_CALCULATION);
    static final DASModesComplexType INACTIVE_STANDALONE_BOARDCALCULATION = createDASModes(INACTIVE, STANDALONE, BOARD_ADVICE_CALCULATION);
    static final DASModesComplexType READONLY_CONNECTED_GROUNDCALCULATION = createDASModes(READ_ONLY, CONNECTED, GROUND_ADVICE_CALCULATION);

    static SFERAB2GRequestMessage createHandshakeRequest(UUID messageId) {
        return createHandshakeRequest(messageId, RU_COMPANY_CODE_SBB_AG, IM_COMPANY_CODE_SBB_INFRA, READONLY_CONNECTED_BOARDCALCULATION);
    }

    static SFERAB2GRequestMessage createHandshakeRequest(UUID messageId, CompanyCode ruCompanyCode, CompanyCode imCompanyCode,
        DASModesComplexType... modes) {
        return createHandshakeRequest(messageId, ruCompanyCode, imCompanyCode, SFERA_VERSION, modes);
    }

    static SFERAB2GRequestMessage createSferaJpRequest(UUID messageId, CompanyCode ruCompanyCode, CompanyCode imCompanyCode,
        String operationalNumberRequest, LocalDate startDate) {
        val messageHeader = createMessageHeader(ruCompanyCode, imCompanyCode, messageId);
        val trainIdentificationRequest = createTrainIdentification(operationalNumberRequest, ruCompanyCode, startDate);
        val jpRequest = createJPRequest(trainIdentificationRequest);
        return createRequestMessage(jpRequest, messageHeader);
    }

    static SFERAB2GRequestMessage createSferaSpRequest(UUID messageId, CompanyCode ruCompanyCodeHeader,
        CompanyCode imCompanyCode, String sPVersionMajor,
        String spVersionMinor, String sPID) {
        val messageHeader = createMessageHeader(ruCompanyCodeHeader, imCompanyCode, messageId);
        val spZone = createSPZone();
        val spRequest = createSPRequest(sPVersionMajor, spVersionMinor, sPID, spZone);
        return createRequestMessage(spRequest, messageHeader);
    }

    private static SFERAB2GRequestMessage createHandshakeRequest(UUID messageId, CompanyCode ruCompanyCode, CompanyCode imCompanyCod, String version,
        DASModesComplexType... modes) {
        val messageHeader = createMessageHeader(ruCompanyCode, imCompanyCod, messageId);
        messageHeader.setSFERAVersion(version);
        val handshakeRequest = new HandshakeRequest();

        for (DASModesComplexType mode : modes) {
            handshakeRequest.getDASOperatingModesSupported().add(mode);
        }

        return createRequestMessage(handshakeRequest, messageHeader);
    }

    private static JPRequest createJPRequest(TrainIdentificationComplexType trainIdentification) {
        val result = new JPRequest();
        result.setTrainIdentification(trainIdentification);
        return result;
    }

    private static SPRequest createSPRequest(String sPVersionMajor, String sPVersionMinor, String sPID, SPZoneComplexType spZone) {
        val result = new SPRequest();
        result.setSPVersionMajor(sPVersionMajor);
        result.setSPVersionMinor(sPVersionMinor);
        result.setSPID(sPID);
        result.setSPZone(spZone);
        return result;
    }

    private static TrainIdentificationComplexType createTrainIdentification(String operationalNumber, CompanyCode companyCode, LocalDate date) {
        val result = new TrainIdentificationComplexType();
        val otnId = new OTNIDComplexType();
        otnId.setTeltsiOperationalTrainNumber(operationalNumber);
        otnId.setTeltsiCompany(companyCode.value());
        otnId.setTeltsiStartDate(XmlDateHelper.toGregorianCalender(date));
        result.setOTNID(otnId);
        return result;
    }

    private static SPZoneComplexType createSPZone() {
        val result = new SPZoneComplexType();
        result.setIMID("0085");
        return result;
    }

    private static MessageHeader createMessageHeader(CompanyCode senderCompanyCode, CompanyCode recipientCompanyCode, UUID messageId) {
        val sender = new Sender();
        sender.setValue(senderCompanyCode.value());

        val recipient = new Recipient();
        recipient.setValue(recipientCompanyCode.value());

        val result = new MessageHeader();
        result.setSFERAVersion(SFERA_VERSION);
        result.setSourceDevice(SOURCE_DEVICE);
        result.setMessageID(messageId.toString());
        result.setSender(sender);
        result.setRecipient(recipient);
        result.setTimestamp(XmlDateHelper.toGregorianCalender(ZonedDateTime.now()));
        return result;
    }

    private static SFERAB2GRequestMessage createRequestMessage(HandshakeRequest handshakeRequest, MessageHeader header) {
        val result = new SFERAB2GRequestMessage();
        result.setMessageHeader(header);
        result.setHandshakeRequest(handshakeRequest);
        return result;
    }

    private static SFERAB2GRequestMessage createRequestMessage(JPRequest jpRequest, MessageHeader header) {
        val result = new SFERAB2GRequestMessage();
        result.setMessageHeader(header);
        val payload = new B2GRequest();
        payload.getJPRequest().add(jpRequest);
        result.setB2GRequest(payload);
        return result;
    }

    private static SFERAB2GRequestMessage createRequestMessage(SPRequest spRequest, MessageHeader header) {
        val result = new SFERAB2GRequestMessage();
        result.setMessageHeader(header);
        val payload = new B2GRequest();
        payload.getSPRequest().add(spRequest);
        result.setB2GRequest(payload);
        return result;
    }

    private static DASModesComplexType createDASModes(ReportedDASDrivingMode.DASDrivingMode drivingMode,
        UnavailableDASOperatingModes.DASConnectivity connectivity,
        UnavailableDASOperatingModes.DASArchitecture architecture) {
        DASModesComplexType modes = new DASModesComplexType();
        modes.setDASDrivingMode(drivingMode);
        modes.setDASConnectivity(connectivity);
        modes.setDASArchitecture(architecture);
        return modes;
    }
}
