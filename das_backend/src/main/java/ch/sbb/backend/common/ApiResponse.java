package ch.sbb.backend.common;

import java.util.List;

public interface ApiResponse<T> {

    List<T> data();
}
