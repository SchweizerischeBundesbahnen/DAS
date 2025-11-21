package ch.sbb.sferamock;

import ch.sbb.sferamock.messages.common.Resettable;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;
import org.springframework.test.context.event.AfterTestExecutionEvent;

@Component
@RequiredArgsConstructor
public class ResetTrigger {

    private final List<Resettable> resettables;

    @EventListener(AfterTestExecutionEvent.class)
    public void onAfterTestExecutionEvent() {
        resettables.forEach(Resettable::reset);
    }
}
