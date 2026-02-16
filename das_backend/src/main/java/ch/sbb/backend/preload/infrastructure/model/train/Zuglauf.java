package ch.sbb.backend.preload.infrastructure.model.train;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NonNull;

@AllArgsConstructor
@Getter
public class Zuglauf {

    @NonNull
    @JsonProperty("solltage_vp")
    Verkehrsperiode solltageVp;

    Boolean verkehrt;

    @NonNull
    List<Zuglaufpunkt> zuglaufpunkte;
}
