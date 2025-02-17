package ch.sbb.sferamock.messages;

import ch.sbb.sferamock.messages.model.ClientId;
import ch.sbb.sferamock.messages.services.RegistrationService;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.ReadOperation;
import org.springframework.boot.actuate.endpoint.annotation.WriteOperation;
import org.springframework.stereotype.Component;

@Component
@Endpoint(id = "sessions")
public class SessionsActuator {

    private final RegistrationService registrationService;

    public SessionsActuator(RegistrationService registrationService) {
        this.registrationService = registrationService;
    }

    @ReadOperation
    public List<Map<String, Object>> getSessions() {
        return registrationService.getRegistrations().entrySet().stream().map(entry -> {
            Map<String, Object> session = new HashMap<>();
            session.put("clientId", entry.getKey().value());
            session.put("companyCode", entry.getValue().trainIdentification().companyCode().value());
            session.put("operationalNumber", entry.getValue().trainIdentification().operationalNumber());
            session.put("date", entry.getValue().trainIdentification().date());
            session.put("timestamp", entry.getValue().timestamp());
            return session;
        }).toList();
    }

    @WriteOperation
    public void nextLocation(String clientId, String operationalNumber, LocalDate date, String companyCode) {
        registrationService.nextLocationEvent(new ClientId(clientId));
    }
}
