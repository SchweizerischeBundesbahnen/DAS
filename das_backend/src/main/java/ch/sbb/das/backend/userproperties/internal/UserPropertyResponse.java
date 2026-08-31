package ch.sbb.das.backend.userproperties.internal;

import ch.sbb.das.backend.common.ApiResponse;
import ch.sbb.das.backend.userproperties.UserProperty;
import java.util.List;

public record UserPropertyResponse(List<UserProperty> data) implements ApiResponse<UserProperty> {
}
