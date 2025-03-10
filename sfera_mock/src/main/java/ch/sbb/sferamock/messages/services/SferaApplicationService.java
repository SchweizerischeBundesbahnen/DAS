package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.HandshakeRejectReason;
import ch.sbb.sferamock.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0201.RelatedTrainInformation;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SPZoneComplexType;
import ch.sbb.sferamock.adapters.sfera.model.v0201.SegmentProfile;
import ch.sbb.sferamock.adapters.sfera.model.v0201.TrainCharacteristics;
import ch.sbb.sferamock.messages.common.SferaErrorCodes;
import ch.sbb.sferamock.messages.model.OperationMode;
import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.model.SegmentIdentification;
import ch.sbb.sferamock.messages.model.TrainCharacteristicsIdentification;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import ch.sbb.sferamock.messages.sfera.ReplyPublisher;
import java.util.List;
import java.util.Objects;
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
    private final TrainCharacteristicsRepository trainCharacteristicsRepository;
    private final EventRepository eventRepository;

    public SferaApplicationService(ReplyPublisher replyPublisher, RequestContextRepository requestContextRepository, OperationModeSelector operationModeSelector,
        RegistrationService registrationService, JourneyProfileRepository journeyProfileRepository, SegmentProfileRepository segmentProfileRepository,
        TrainCharacteristicsRepository trainCharacteristicsRepository, EventRepository eventRepository) {
        this.replyPublisher = replyPublisher;
        this.requestContextRepository = requestContextRepository;
        this.operationModeSelector = operationModeSelector;
        this.registrationService = registrationService;
        this.journeyProfileRepository = journeyProfileRepository;
        this.segmentProfileRepository = segmentProfileRepository;
        this.trainCharacteristicsRepository = trainCharacteristicsRepository;
        this.eventRepository = eventRepository;
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
        var journeyProfile = journeyProfileRepository.getJourneyProfile(trainIdentification, registrationService.getTimestamp(requestContext.clientId()));
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

    public void processTrainCharacteristicsRequest(List<TrainCharacteristicsIdentification> trainCharacteristicsIdentifications, RequestContext requestContext) {
        if (!registrationService.isRegistered(requestContext.clientId())) {
            publishErrorMessageUnregisteredClient(requestContext);
            return;
        }

        var correlationId = UUID.randomUUID();
        requestContextRepository.storeRequestContext(correlationId, requestContext);

        var trainCharacteristics = trainCharacteristicsIdentifications.stream()
            .map(trainCharacteristicsIdentification -> trainCharacteristicsRepository.getTrainCharacteristics(trainCharacteristicsIdentification)
                .orElse(null))
            .filter(Objects::nonNull)
            .toList();
        publishTrainCharacteristics(trainCharacteristics, correlationId, requestContext);
    }

    public void processRelatedTrainInformationRequest(List<TrainIdentification> trainIdentifications, RequestContext requestContext) {
        if (!registrationService.isRegistered(requestContext.clientId())) {
            publishErrorMessageUnregisteredClient(requestContext);
            return;
        }

        var correlationId = UUID.randomUUID();
        requestContextRepository.storeRequestContext(correlationId, requestContext);

        List<RelatedTrainInformation> relatedTrainInformations = trainIdentifications.stream().map(trainIdentification ->
                eventRepository.getRelatedTrainInformation(trainIdentification).orElse(null))
            .filter(Objects::nonNull)
            .toList();

        publishRelatedTrainInformations(relatedTrainInformations, correlationId, requestContext);
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

    private void publishTrainCharacteristics(List<TrainCharacteristics> trainCharacteristics, UUID correlationId, RequestContext requestContext) {
        requestContextRepository.getRequestContext(correlationId)
            .ifPresentOrElse(it -> publishTrainCharacteristicsResponse(trainCharacteristics, it), () -> replyPublisher.publishErrorMessage(SferaErrorCodes.COULD_NOT_PROCESS_DATA, requestContext));
    }

    private void publishTrainCharacteristicsResponse(List<TrainCharacteristics> trainCharacteristics, RequestContext requestContext) {
        if (!trainCharacteristics.isEmpty()) {
            replyPublisher.publishTrainCharacteristics(trainCharacteristics, requestContext);
        } else {
            replyPublisher.publishErrorMessage(SferaErrorCodes.COULD_NOT_PROCESS_DATA, requestContext);
        }
    }

    private void publishRelatedTrainInformations(List<RelatedTrainInformation> relatedTrainInformations, UUID correlationId, RequestContext requestContext) {
        requestContextRepository.getRequestContext(correlationId)
            .ifPresentOrElse(it -> publishRelatedTrainInformationsResponse(relatedTrainInformations, it),
                () -> replyPublisher.publishErrorMessage(SferaErrorCodes.COULD_NOT_PROCESS_DATA, requestContext));
    }

    private void publishRelatedTrainInformationsResponse(List<RelatedTrainInformation> relatedTrainInformations, RequestContext requestContext) {
        if (!relatedTrainInformations.isEmpty()) {
            replyPublisher.publishRelatedTrainInformations(relatedTrainInformations, requestContext);
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
            replyPublisher.publishHandshakeReject(HandshakeRejectReason.ARCHITECTURE_NOT_SUPPORTED, requestContext);
        } else {
            replyPublisher.publishErrorMessage(SferaErrorCodes.INCONSISTENT_DATA, requestContext);
        }
    }
}
