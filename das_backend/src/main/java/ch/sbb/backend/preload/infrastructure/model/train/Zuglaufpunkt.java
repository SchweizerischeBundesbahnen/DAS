package ch.sbb.backend.preload.infrastructure.model.train;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Getter
public class Zuglaufpunkt {

    @NonNull
    Betriebspunkt betriebspunkt;

    @JsonProperty("kommerzielle_zeit_ab")
    Integer kommZeitAb;  // nullable

    @JsonProperty("betr_zeit_ab")
    Integer betrZeitAb;  // nullable

    @JsonProperty("sms_evu")
    String smsEvu; // nullable

}
