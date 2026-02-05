package ch.sbb.backend.preload.infrastructure.model.traindata;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.NonNull;

@Getter
public class Betriebspunkt {

    @NonNull
    @JsonProperty("bp_abkuerzung")
    String bpAbkuerzung;

    @NonNull
    @JsonProperty("bp_uic_code")
    Integer bpUicCode;

    @NonNull
    @JsonProperty("bp_uic_laendercode")
    Integer bpUicLaendercode;

}
