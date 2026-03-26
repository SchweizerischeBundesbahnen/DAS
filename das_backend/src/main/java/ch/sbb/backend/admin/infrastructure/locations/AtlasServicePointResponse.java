package ch.sbb.backend.admin.infrastructure.locations;

import java.util.List;

public record AtlasServicePointResponse(List<AtlasServicePoint> objects, Integer totalCount) {

}
