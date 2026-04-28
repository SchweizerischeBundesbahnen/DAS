package ch.sbb.das.backend.admin.infrastructure.atlas;

import java.util.List;

public record ServicePointResponse(List<ServicePoint> objects, Integer totalCount) {

}
