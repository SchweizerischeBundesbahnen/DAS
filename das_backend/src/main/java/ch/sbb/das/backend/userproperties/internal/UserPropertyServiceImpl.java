package ch.sbb.das.backend.userproperties.internal;

import ch.sbb.das.backend.userproperties.UserProperty;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

@Service
@RequiredArgsConstructor
class UserPropertyServiceImpl {

    static final int MAX_VALUE_LENGTH = 4096;

    private final UserPropertyRepository userPropertyRepository;
    private final JsonMapper jsonMapper;

    List<UserProperty> getAllByOid(String oid) {
        return userPropertyRepository.findAllByOid(oid).stream()
            .map(this::toUserProperty)
            .toList();
    }

    Optional<UserProperty> getByOidAndKey(String oid, String key) {
        return userPropertyRepository.findByOidAndKey(oid, key)
            .map(this::toUserProperty);
    }

    @Transactional
    UserProperty save(String oid, String key, JsonNode value) {
        String serializedValue = jsonMapper.writeValueAsString(value);
        if (serializedValue.length() > MAX_VALUE_LENGTH) {
            throw new ResponseStatusException(HttpStatus.CONTENT_TOO_LARGE,
                "User property value exceeds the maximum allowed length of " + MAX_VALUE_LENGTH + " characters.");
        }
        UserPropertyEntity entity = userPropertyRepository.findByOidAndKey(oid, key)
            .orElseGet(() -> {
                UserPropertyEntity newEntity = new UserPropertyEntity();
                newEntity.setOid(oid);
                newEntity.setKey(key);
                return newEntity;
            });
        entity.setValue(serializedValue);
        return toUserProperty(userPropertyRepository.save(entity));
    }

    private UserProperty toUserProperty(UserPropertyEntity entity) {
        return new UserProperty(entity.getKey(), jsonMapper.readTree(entity.getValue()), entity.getLastModifiedAt());
    }
}
