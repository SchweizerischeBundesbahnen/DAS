package ch.sbb.das.backend.common;

import java.util.List;

/**
 * Every successful response body wraps its payload in {@code data}, so that the top-level JSON structure is an object and stays extensible.
 *
 * @see <a href="https://schweizerischebundesbahnen.github.io/api-principles/restful/best-practices/#always-return-json-objects-as-top-level-data-structures-to-support-extensibility">SBB API Principles</a>
 * @see <a href="https://opensource.zalando.com/restful-api-guidelines/#110">MUST always return JSON objects as top-level data structures [110]</a>
 */
public interface ApiResponse<T> {

    List<T> data();
}
