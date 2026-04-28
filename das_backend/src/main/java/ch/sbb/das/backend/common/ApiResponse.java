package ch.sbb.das.backend.common;

import java.util.List;

public interface ApiResponse<T> extends Response {

    List<T> data();
}
