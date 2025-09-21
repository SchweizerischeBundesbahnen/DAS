package ch.sbb.sferamock.messages.services;

import ch.sbb.sferamock.adapters.sfera.model.v0201.G2BEventPayload;
import ch.sbb.sferamock.adapters.sfera.model.v0201.JourneyProfile;
import ch.sbb.sferamock.messages.common.XmlDateHelper;
import ch.sbb.sferamock.messages.common.XmlHelper;
import ch.sbb.sferamock.messages.model.ClientId;
import ch.sbb.sferamock.messages.model.RequestContext;
import ch.sbb.sferamock.messages.services.EventRepository.Event;
import ch.sbb.sferamock.messages.sfera.EventPublisher;
import java.time.Instant;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.Comparator;
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
    private final XmlHelper xmlHelper;
    private final Map<ClientId, List<ScheduledFuture<?>>> scheduledTasks = new ConcurrentHashMap<>();

    public EventService(EventRepository eventRepository, EventPublisher eventPublisher, XmlHelper xmlHelper) {
        this.eventRepository = eventRepository;
        this.eventPublisher = eventPublisher;
        this.xmlHelper = xmlHelper;
        this.taskScheduler = new ThreadPoolTaskScheduler();
        this.taskScheduler.initialize();
    }

    public void registerActiveTrain(RequestContext requestContext, ZonedDateTime registrationTime) {
        if (requestContext.tid().isManualEvents() || hasActiveFutures(requestContext.clientId())) {
            return;
        }
        List<Event> events = this.eventRepository.events.get(requestContext.tid().baseOperationalNumber());
        if (events == null) {
            return;
        }
        List<ScheduledFuture<?>> futures = new ArrayList<>();
        for (Event event : events) {
            ScheduledFuture<?> future = taskScheduler.schedule(() -> processEvent(event.payload(), requestContext, registrationTime), Instant.now().plusMillis(event.offsetMs()));
            futures.add(future);
        }
        scheduledTasks.put(requestContext.clientId(), futures);
    }

    public void nextEvent(RequestContext requestContext, int manualEventIndex, ZonedDateTime registrationTime) {
        var event = this.eventRepository.events.get(requestContext.tid().baseOperationalNumber()).stream()
            .sorted(Comparator.comparingInt(Event::offsetMs))
            .toList()
            .get(manualEventIndex);
        processEvent(event.payload(), requestContext, registrationTime);
    }

    public void deregisterActiveTrain(ClientId clientId) {
        List<ScheduledFuture<?>> futures = scheduledTasks.remove(clientId);
        if (futures != null) {
            for (ScheduledFuture<?> future : futures) {
                future.cancel(false);
            }
        }
    }

    private void processEvent(G2BEventPayload eventPayload, RequestContext requestContext, ZonedDateTime registrationTime) {
        if (eventPayload.getRelatedTrainInformation() != null) {
            eventPublisher.publishRelatedTrainInformation(eventPayload, requestContext);
        } else if (eventPayload.getJourneyProfile() != null) {
            eventPayload = replaceDateTimes(eventPayload, registrationTime);
            eventPublisher.publishJourneyProfile(eventPayload, requestContext);
        } else {
            eventPublisher.publishEventPayload(eventPayload, requestContext);
        }
    }

    private boolean hasActiveFutures(ClientId clientId) {
        List<ScheduledFuture<?>> scheduledFutures = scheduledTasks.get(clientId);
        return scheduledFutures != null && scheduledFutures.stream().anyMatch(scheduledFuture -> !scheduledFuture.isDone() && !scheduledFuture.isCancelled());
    }

    private G2BEventPayload replaceDateTimes(G2BEventPayload eventPayload, ZonedDateTime registrationTime) {
        var copiedEventPayload = xmlHelper.deepCopy(eventPayload);
        List<JourneyProfile> journeyProfiles = copiedEventPayload.getJourneyProfile();
        journeyProfiles.forEach(journeyProfile -> XmlDateHelper.replaceDateTimes(journeyProfile, registrationTime));
        return copiedEventPayload;
    }
}
