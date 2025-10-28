package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.messages.common.Resettable;
import ch.sbb.sferamock.messages.model.ClientId;
import ch.sbb.sferamock.messages.model.OperationMode;
import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import ch.sbb.sferamock.messages.model.Version;
import java.time.ZonedDateTime;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentSkipListSet;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

@Service
public class RegistrationService implements Resettable {

    private static final Logger log = LogManager.getLogger(RegistrationService.class);
    private final Map<TrainIdentification, Set<ClientId>> activeTrains = new ConcurrentHashMap<>();
    private final Map<ClientId, Registration> registrationMap = new ConcurrentHashMap<>();

    private final EventService eventService;

    public RegistrationService(EventService eventService) {
        this.eventService = eventService;
    }

    private static Set<ClientId> existingSetWith(Set<ClientId> clientIdentifiers, ClientId newClientId) {
        clientIdentifiers.add(newClientId);
        return clientIdentifiers;
    }

    private static Set<ClientId> newSetWith(ClientId clientId) {
        var result = new ConcurrentSkipListSet<ClientId>();
        result.add(clientId);
        return result;
    }

    public void register(RequestContext requestContext, OperationMode selectedMode) {
        registerClientIdAndTrain(requestContext, selectedMode);
    }

    private void registerClientIdAndTrain(RequestContext requestContext, OperationMode operationMode) {
        var clientId = requestContext.clientId();
        var trainIdentification = requestContext.tid();
        log.info("Registering DAS Client {} with company {}, train {}, date {}", clientId, trainIdentification.companyCode(), trainIdentification.operationalNumber(), trainIdentification.date());
        var registration = new Registration(trainIdentification, operationMode, requestContext.version());
        registrationMap.put(clientId, registration);

        if (operationMode.sendJourneyProfileUpdates()) {
            activeTrains.compute(trainIdentification, (key, clientIdentifiers) -> clientIdentifiers == null
                ? newSetWith(clientId)
                : existingSetWith(clientIdentifiers, clientId));
            eventService.registerActiveTrain(requestContext, registration.timestamp);
        }
    }

    public void deregisterClient(ClientId clientId) {
        deregisterTrainIfLastClient(clientId);
        eventService.deregisterActiveTrain(clientId);
        registrationMap.remove(clientId);
    }

    public Map<ClientId, Registration> getRegistrations() {
        return this.registrationMap;
    }

    private void deregisterTrainIfLastClient(ClientId clientId) {
        if (registrationMap.containsKey(clientId)) {
            var currentTrainIdentification = registrationMap.get(clientId).trainIdentification();
            activeTrains.computeIfPresent(currentTrainIdentification, (tid, clientIdentifiers) -> {
                if (clientIdentifiers.remove(clientId)) {
                    if (clientIdentifiers.isEmpty()) {
                        return null;
                    }
                }
                return clientIdentifiers;
            });
        }
    }

    public boolean isRegistered(ClientId clientId) {
        return registrationMap.containsKey(clientId);
    }

    @Override
    public void reset() {
        registrationMap.clear();
        activeTrains.clear();
    }

    public void nextEvent(ClientId clientId) {
        if (isRegistered(clientId)) {
            var registration = registrationMap.get(clientId);
            if (registration.trainIdentification.isManualEvents()) {
                eventService.nextEvent(new RequestContext(registration.trainIdentification, clientId, registration.version), registration.manualEventIndex, registration.timestamp);
                registrationMap.put(clientId,
                    new Registration(registration.trainIdentification, registration.operationMode, registration.version, registration.timestamp, registration.manualEventIndex + 1));
            }
        }
    }

    public ZonedDateTime getTimestamp(ClientId clientId) {
        return registrationMap.get(clientId).timestamp;
    }

    public record Registration(TrainIdentification trainIdentification, OperationMode operationMode, Version version, ZonedDateTime timestamp, int manualEventIndex) {

        public Registration(TrainIdentification trainIdentification, OperationMode operationMode, Version version) {
            this(trainIdentification, operationMode, version, ZonedDateTime.now(), 0);
        }
    }
}
