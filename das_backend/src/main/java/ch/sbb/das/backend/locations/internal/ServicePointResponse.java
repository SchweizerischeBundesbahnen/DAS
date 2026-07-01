package ch.sbb.das.backend.locations.internal;

import java.util.List;

public record ServicePointResponse(List<ServicePoint> objects, Integer totalCount) {

}
