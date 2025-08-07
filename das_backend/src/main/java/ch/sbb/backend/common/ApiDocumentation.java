package ch.sbb.backend.common;

import lombok.experimental.UtilityClass;
import org.springframework.http.HttpHeaders;

@UtilityClass
public final class ApiDocumentation {

    public static final String VERSION_URI_V1 = "/v1";

    public static final String STATUS_400 = "Bad request";
    public static final String STATUS_401 = "Unauthorized";
    public static final String STATUS_404 = "No entity/resource found";
    public static final String STATUS_304 = "Resource was not modified since last request to the client.";
    public static final String STATUS_500 = "Internal server error";

    public static final String HEADER_CACHE_CONTROL = HttpHeaders.CACHE_CONTROL;
    public static final String HEADER_CACHE_ETAG = HttpHeaders.ETAG;
    public static final String SAMPLE_CACHE_ETAG = "\"0ec6239c745a9454f10fcd977a9c465a1\"";
    public static final String HEADER_CACHE_CONTROL_RESPONSE_DESCRIPTION = "The `" + HEADER_CACHE_CONTROL
        + "` response header field is providing **directives to control how proxies and clients are allowed to cache "
        + "responses** for performance. [RFC-7234 section 5.2.2](https://tools.ietf.org/html/rfc7234#section-5.2.2).";
    public static final String HEADER_CACHE_ETAG_RESPONSE_DESCRIPTION = "ETag for this response snapshot, "
        + "which can be sent back with `" + HttpHeaders.IF_NONE_MATCH + "` request header, "
        + "according to [RFC-7232](https://www.rfc-editor.org/rfc/rfc7232).";
    public static final String HEADER_CACHE_IF_NONE_MATCH_DESCRIPTION = "An optional ETag"
        + " given in a previous response header _" + HttpHeaders.ETAG + "_ and which can save network traffic.";
}
