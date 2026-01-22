package ch.sbb.backend.common.model.response;

import java.util.List;

public interface ApiResponse<T> extends Response {

    List<T> data();
}
