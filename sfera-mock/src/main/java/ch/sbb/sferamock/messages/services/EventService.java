package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.G2BEventPayload;
import ch.sbb.sferamock.messages.model.ClientId;
import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.services.EventRepository.Event;
import ch.sbb.sferamock.messages.sfera.EventPublisher;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ScheduledFuture;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.stereotype.Service;

@Service
public class EventService {

    private final EventRepository eventRepository;
    private final ThreadPoolTaskScheduler taskScheduler;
    private final EventPublisher eventPublisher;
    private final Map<ClientId, List<ScheduledFuture<?>>> scheduledTasks = new ConcurrentHashMap<>();

    public EventService(EventRepository eventRepository, EventPublisher eventPublisher) {
        this.eventRepository = eventRepository;
        this.eventPublisher = eventPublisher;
        this.taskScheduler = new ThreadPoolTaskScheduler();
        this.taskScheduler.initialize();
    }

    public void registerActiveTrain(RequestContext requestContext) {
        if (hasActiveFutures(requestContext.clientId())) {
            return;
        }
        List<Event> events = this.eventRepository.events.get(requestContext.tid().operationalNumber());
        if (events == null) {
            return;
        }
        List<ScheduledFuture<?>> futures = new ArrayList<>();
        for (Event event : events) {
            ScheduledFuture<?> future = taskScheduler.schedule(() -> processEvent(event.payload(), requestContext), Instant.now().plusMillis(event.offsetMs()));
            futures.add(future);
        }
        scheduledTasks.put(requestContext.clientId(), futures);
    }

    public void nextLocationEvent(RequestContext requestContext, int manualLocationIndex) {
        var event = this.eventRepository.events.get(requestContext.tid().baseOperationalNumber()).get(manualLocationIndex);
        eventPublisher.publishRelatedTrainInformation(event.payload(), requestContext);
    }

    public void deregisterActiveTrain(ClientId clientId) {
        List<ScheduledFuture<?>> futures = scheduledTasks.remove(clientId);
        if (futures != null) {
            for (ScheduledFuture<?> future : futures) {
                future.cancel(false);
            }
        }
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

    private boolean hasActiveFutures(ClientId clientId) {
        List<ScheduledFuture<?>> scheduledFutures = scheduledTasks.get(clientId);
        return scheduledFutures != null && scheduledFutures.stream().anyMatch(scheduledFuture -> !scheduledFuture.isDone() && !scheduledFuture.isCancelled());
    }
}
