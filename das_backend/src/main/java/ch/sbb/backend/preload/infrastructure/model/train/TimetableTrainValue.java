package ch.sbb.backend.preload.infrastructure.model.train;

import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@AllArgsConstructor
@Getter
public class TimetableTrainValue {

    public enum Sicht {
        VT,
        PT,
        KT,
        OT
    }

    @NonNull
    String zugnummer;

    @NonNull
    Integer fahrplanperiode;

    @NonNull
    String trassenID;

    @NonNull
    TimetableTrainValue.Sicht sicht;

    @NonNull
    List<Zuglauf> zuglaeufe;
}
