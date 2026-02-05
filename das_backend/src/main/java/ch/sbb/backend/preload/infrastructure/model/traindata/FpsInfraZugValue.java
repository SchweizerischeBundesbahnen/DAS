package ch.sbb.backend.preload.infrastructure.model.traindata;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NonNull;

@Builder
@AllArgsConstructor
@Getter
public class FpsInfraZugValue {

    public enum Sicht {
        VT,
        PT,
        KT,
        OT
    }

    public enum VerstaendigungsStatus {
        OEFFENTLICH,
        VERSTAENDIGT
    }

    @NonNull
    String zugnummer;

    @NonNull
    Integer fahrplanperiode;

    @NonNull
    String trassenID;

    @NonNull
    FpsInfraZugValue.Sicht sicht;

    @JsonProperty("verstaendigungs_status")
    @NonNull
    FpsInfraZugValue.VerstaendigungsStatus verstaendigungsStatus;

    @NonNull
    String infrastrukturnetz;

    @JsonProperty("bestell_evu")
    @NonNull
    String bestellEvu;

    @NonNull
    List<Zuglauf> zuglaeufe;
}
