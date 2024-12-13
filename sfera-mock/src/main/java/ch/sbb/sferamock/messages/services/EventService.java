package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.G2BEventPayload;
import ch.sbb.sferamock.messages.model.ClientId;
import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.services.EventRepository.Event;
import ch.sbb.sferamock.messages.sfera.EventPublisher;
import java.time.Instant;
import java.util.List;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.stereotype.Service;

@Service
public class EventService {

    private final EventRepository eventRepository;
    private final ThreadPoolTaskScheduler taskScheduler;
    private final EventPublisher eventPublisher;

    public EventService(EventRepository eventRepository, EventPublisher eventPublisher) {
        this.eventRepository = eventRepository;
        this.eventPublisher = eventPublisher;
        this.taskScheduler = new ThreadPoolTaskScheduler();
        this.taskScheduler.initialize();
    }

    public void registerActiveTrain(RequestContext requestContext) {
        List<Event> events = this.eventRepository.events.get(requestContext.tid().operationalNumber());
        if (events == null) {
            return;
        }
        for (Event event : events) {
            taskScheduler.schedule(() -> processEvent(event.payload(), requestContext), Instant.now().plusMillis(event.offsetMs()));
        }
    }

    public void deregisterActiveTrain(ClientId clientId) {

    }

    private void processEvent(G2BEventPayload eventPayload, RequestContext requestContext) {
        if (eventPayload.getRelatedTrainInformation() != null) {
            eventPublisher.publishRelatedTrainInformation(eventPayload, requestContext);
        } else if (eventPayload.getJourneyProfile() != null) {
            eventPublisher.publishJourneyProfile(eventPayload, requestContext);
        } else {
            eventPublisher.publishEventPayload(eventPayload, requestContext);
        }
    }

}
