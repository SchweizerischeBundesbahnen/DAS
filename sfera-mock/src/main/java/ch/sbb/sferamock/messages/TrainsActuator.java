package ch.sbb.sferamock.messages;

import ch.sbb.sferamock.messages.services.JourneyProfileRepository;
import java.util.Set;
import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.ReadOperation;
import org.springframework.stereotype.Component;

@Component
@Endpoint(id = "trains")
public class TrainsActuator {

    private final JourneyProfileRepository journeyProfileRepository;

    public TrainsActuator(JourneyProfileRepository journeyProfileRepository) {
        this.journeyProfileRepository = journeyProfileRepository;
    }

    @ReadOperation
    public Set<String> getJps() {
        return journeyProfileRepository.getAvailableJourneyProfiles();
    }
}
