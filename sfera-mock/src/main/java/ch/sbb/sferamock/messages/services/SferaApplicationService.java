package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SPZoneComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.sferamock.messages.common.SferaErrorCodes;
import ch.sbb.sferamock.messages.model.HandshakeRejectReason;
import ch.sbb.sferamock.messages.model.OperationMode;
import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.model.SegmentIdentification;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import ch.sbb.sferamock.messages.sfera.ReplyPublisher;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class SferaApplicationService {

    private static final Logger log = LoggerFactory.getLogger(SferaApplicationService.class);
    private final ReplyPublisher replyPublisher;
    private final RequestContextRepository requestContextRepository;
    private final OperationModeSelector operationModeSelector;
    private final RegistrationService registrationService;
    private final JourneyProfileRepository journeyProfileRepository;
    private final SegmentProfileRepository segmentProfileRepository;

    public SferaApplicationService(ReplyPublisher replyPublisher, RequestContextRepository requestContextRepository, OperationModeSelector operationModeSelector,
        RegistrationService registrationService, JourneyProfileRepository journeyProfileRepository, SegmentProfileRepository segmentProfileRepository) {
        this.replyPublisher = replyPublisher;
        this.requestContextRepository = requestContextRepository;
        this.operationModeSelector = operationModeSelector;
        this.registrationService = registrationService;
        this.journeyProfileRepository = journeyProfileRepository;
        this.segmentProfileRepository = segmentProfileRepository;
    }

    private static JourneyProfile unavailableJourneyProfile() {
        var jp = new JourneyProfile();
        jp.setJPStatus("Unavailable");
        return jp;
    }

    private static SegmentProfile invalidSp(SegmentIdentification segmentIdentification) {
        var sp = new SegmentProfile();
        sp.setSPStatus("Invalid");
        sp.setSPID(segmentIdentification.id());
        sp.setSPVersionMajor(segmentIdentification.majorVersion());
        sp.setSPVersionMinor(segmentIdentification.minorVersion());
        var spZone = new SPZoneComplexType();
        spZone.setIMID(segmentIdentification.zone().value());
        sp.setSPZone(spZone);
        return sp;
    }

    public void processHandshakeRequest(List<OperationMode> supportedOperationModes, boolean statusReportEnabled, RequestContext requestContext) {
        var selectedMode = operationModeSelector.selectOperationMode(supportedOperationModes, statusReportEnabled);

        selectedMode.ifPresentOrElse(it -> {
            registrationService.register(requestContext, it);
            replyPublisher.publishHandshakeAcknowledge(it.connectivity(), it.architecture(), requestContext);
        }, () -> errorOrReject(supportedOperationModes, requestContext));
    }

    public void processJourneyProfileRequest(TrainIdentification trainIdentification, RequestContext requestContext) {
        if (!registrationService.isRegistered(requestContext.clientId())) {
            publishErrorMessageUnregisteredClient(requestContext);
            return;
        }
        if (!trainIdentification.equals(requestContext.tid())) {
            log.warn("Inconsistent train identification: header {}, request {}", requestContext.tid(), trainIdentification);
            replyPublisher.publishErrorMessage(SferaErrorCodes.INCONSISTENT_DATA, requestContext);
            return;
        }

        var correlationId = UUID.randomUUID();
        requestContextRepository.storeRequestContext(correlationId, requestContext);
        var journeyProfile = journeyProfileRepository.getJourneyProfile(trainIdentification);
        publishJourneyProfile(journeyProfile, correlationId, requestContext);
    }

    public void processSegmentProfileRequest(List<SegmentIdentification> segmentIdentifications, RequestContext requestContext) {
        if (!registrationService.isRegistered(requestContext.clientId())) {
            publishErrorMessageUnregisteredClient(requestContext);
            return;
        }

        var correlationId = UUID.randomUUID();
        requestContextRepository.storeRequestContext(correlationId, requestContext);

        var segmentProfiles = segmentIdentifications.stream()
            .map(segmentIdentification -> segmentProfileRepository.getSegmentProfile(segmentIdentification)
                .orElse(invalidSp(segmentIdentification)))
            .toList();
        publishSegmentProfile(segmentProfiles, correlationId, requestContext);
    }

    public void processSessionTermination(RequestContext requestContext) {
        if (!registrationService.isRegistered(requestContext.clientId())) {
            publishErrorMessageUnregisteredClient(requestContext);
            return;
        }
        registrationService.deregisterClient(requestContext.clientId());
        publishOk(requestContext);
    }

    private void publishJourneyProfile(Optional<JourneyProfile> journeyProfile, UUID correlationId, RequestContext requestContext) {
        requestContextRepository.getRequestContext(correlationId)
            .ifPresentOrElse(it -> publishJourneyProfileResponse(journeyProfile, it), () -> replyPublisher.publishErrorMessage(SferaErrorCodes.COULD_NOT_PROCESS_DATA, requestContext));
    }

    private void publishJourneyProfileResponse(Optional<JourneyProfile> journeyProfile, RequestContext requestContext) {
        var responseToPublish = journeyProfile.orElseGet(SferaApplicationService::unavailableJourneyProfile);
        replyPublisher.publishJourneyProfile(responseToPublish, requestContext);
    }

    private void publishSegmentProfile(List<SegmentProfile> segmentProfiles, UUID correlationId, RequestContext requestContext) {
        requestContextRepository.getRequestContext(correlationId)
            .ifPresentOrElse(it -> publishSegmentProfileResponse(segmentProfiles, it), () -> replyPublisher.publishErrorMessage(SferaErrorCodes.COULD_NOT_PROCESS_DATA, requestContext));
    }

    private void publishSegmentProfileResponse(List<SegmentProfile> segmentProfiles, RequestContext requestContext) {
        if (!segmentProfiles.isEmpty()) {
            replyPublisher.publishSegmentProfile(segmentProfiles, requestContext);
        } else {
            replyPublisher.publishErrorMessage(SferaErrorCodes.COULD_NOT_PROCESS_DATA, requestContext);
        }
    }

    private void publishOk(RequestContext requestContext) {
        replyPublisher.publishOkMessage(requestContext);
    }

    private void publishErrorMessageUnregisteredClient(RequestContext requestContext) {
        log.warn("Received a request from an unregistered client id {}", requestContext.clientId());
        replyPublisher.publishErrorMessage(SferaErrorCodes.COULD_NOT_PROCESS_DATA, requestContext);
    }

    private void errorOrReject(List<OperationMode> dasOperatingModesSupported, RequestContext requestContext) {
        if (operationModeSelector.hasWrongArchitecture(dasOperatingModesSupported)) {
            replyPublisher.publishHandshakeReject(HandshakeRejectReason.architectureNotSupported, requestContext);
        } else {
            replyPublisher.publishErrorMessage(SferaErrorCodes.INCONSISTENT_DATA, requestContext);
        }
    }
}
