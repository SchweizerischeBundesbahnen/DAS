package ch.sbb.backend.preload.infrastructure.model.train;

import lombok.Getter;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;

@RequiredArgsConstructor
@Getter
public class TimetableTrainKey {

    @NonNull
    String id;

}
