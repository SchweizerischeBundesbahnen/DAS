package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.messages.model.ClientId;
import ch.sbb.sferamock.messages.model.OperationMode;
import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.model.TrainIdentification;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentSkipListSet;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

@Service
public class RegistrationService {

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
        var registration = new Registration(trainIdentification, operationMode);
        registrationMap.put(clientId, registration);

        if (operationMode.sendJourneyProfileUpdates()) {
            activeTrains.compute(trainIdentification, (key, clientIdentifiers) -> clientIdentifiers == null
                ? newSetWith(clientId)
                : existingSetWith(clientIdentifiers, clientId));
        }
        eventService.registerActiveTrain(requestContext);
    }

    public void deregisterClient(ClientId clientId) {
        deregisterTrainIfLastClient(clientId);
        eventService.deregisterActiveTrain(clientId);
        registrationMap.remove(clientId);
    }

    private void deregisterTrainIfLastClient(ClientId clientId) {
        if (registrationMap.containsKey(clientId)) {
            var currentTrainIdentification = registrationMap.get(clientId).trainIdentification();
            activeTrains.compute(currentTrainIdentification, (tid, clientIdentifiers) -> {
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

    public void reset() {
        registrationMap.clear();
        activeTrains.clear();
    }

    public record Registration(TrainIdentification trainIdentification, OperationMode operationMode) {

    }
}
