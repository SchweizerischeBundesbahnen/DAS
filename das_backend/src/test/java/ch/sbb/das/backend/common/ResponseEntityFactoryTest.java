package ch.sbb.das.backend.common;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import lombok.Data;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

class ResponseEntityFactoryTest {

    @Test
    void createOkResponse_defaultHeaders() {
        final DummyEntry entry = new DummyEntry();
        entry.setField("myTest");
        final DummyResponse response = new DummyResponse();
        response.getData().add(entry);

        ResponseEntity<DummyResponse> responseEntity = ResponseEntityFactory.createOkResponse(response, null);
        assertThat(responseEntity.getBody()).isEqualTo(response);
        assertThat(responseEntity.getHeaders().getContentType()).isEqualTo(MediaType.APPLICATION_JSON);
        assertThat(responseEntity.getHeaders().getContentLanguage()).isNull();
    }

    @Test
    void createOkResponse_withAdditionalHeaders() {
        final DummyEntry entry = new DummyEntry();
        entry.setField("myTest");
        final DummyResponse response = new DummyResponse();
        response.getData().add(entry);

        ResponseEntity<DummyResponse> responseEntity = ResponseEntityFactory.createOkResponse(response, Locale.FRENCH);
        assertThat(responseEntity.getBody()).isEqualTo(response);
        assertThat(responseEntity.getHeaders().getContentType()).isEqualTo(MediaType.APPLICATION_JSON);
        assertThat(responseEntity.getHeaders().getContentLanguage().toLanguageTag()).isEqualTo("fr");
        assertThat(responseEntity.getHeaders().containsHeader(ApiParametersDefault.HEADER_REQUEST_ID)).as("set centrally by RequestIdFilter").isFalse();
    }

    @Test
    void createNotFoundResponse() {
        ResponseEntity<Problem> responseEntity = ResponseEntityFactory.createNotFoundResponse("notFound", "Pojo not found", null, "/nowhere");
        assertThat(responseEntity.getHeaders().getContentType()).isEqualTo(MediaType.APPLICATION_PROBLEM_JSON);
        assertThat(responseEntity.getHeaders().getContentLanguage().toString()).isEqualTo("en");
        assertThat(responseEntity.getHeaders().containsHeader(ApiParametersDefault.HEADER_REQUEST_ID)).as("set centrally by RequestIdFilter").isFalse();
        assertThat(responseEntity.getBody()).isInstanceOf(Problem.class);
        assertThat(responseEntity.getBody().getStatus()).isEqualTo(404);
        assertThat(responseEntity.getBody().getTitle()).isEqualTo("notFound");
        assertThat(responseEntity.getBody().getDetail()).isEqualTo("Pojo not found");
        assertThat(responseEntity.getBody().getInstance().toString()).isEqualTo("/nowhere");
        assertThat(responseEntity.getBody().getType()).isNull();
    }

    @Data
    public static class DummyEntry {

        String field;
    }

    @Data
    public static class DummyResponse implements ApiResponse<DummyEntry> {

        private List<DummyEntry> data = new ArrayList<>();

        @Override
        public List<DummyEntry> data() {
            return data;
        }
    }
}
