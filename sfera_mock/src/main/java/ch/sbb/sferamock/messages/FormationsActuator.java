package ch.sbb.sferamock.messages;

import ch.sbb.sferamock.messages.services.FormationsService;
import java.io.IOException;
import java.time.LocalDate;
import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.WriteOperation;
import org.springframework.stereotype.Component;

@Component
@Endpoint(id = "formations")
public class FormationsActuator {

    private final FormationsService formationsService;

    public FormationsActuator(FormationsService formationsService) {
        this.formationsService = formationsService;
    }

    @WriteOperation
    public void pushFormation(FormationState state, String operationalTrainNumber, LocalDate operationalDay, String companyCode) throws IOException {
        switch (state) {
            case INITIAL -> formationsService.initialState(operationalTrainNumber, operationalDay, companyCode);
            case FormationState.UPDATED -> formationsService.updatedState(operationalTrainNumber, operationalDay, companyCode);
            default -> throw new IllegalStateException("Unknown state " + state);
        }
    }
}
