package ch.sbb.das.backend.userproperties.internal;

import ch.sbb.das.backend.userproperties.UserProperty;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

@Service
@RequiredArgsConstructor
class UserPropertyServiceImpl {

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

    UserProperty save(String oid, String key, JsonNode value) {
        UserPropertyEntity entity = userPropertyRepository.findByOidAndKey(oid, key)
            .orElseGet(() -> {
                UserPropertyEntity newEntity = new UserPropertyEntity();
                newEntity.setOid(oid);
                newEntity.setKey(key);
                return newEntity;
            });
        entity.setValue(jsonMapper.writeValueAsString(value));
        return toUserProperty(userPropertyRepository.save(entity));
    }

    private UserProperty toUserProperty(UserPropertyEntity entity) {
        return new UserProperty(entity.getKey(), jsonMapper.readTree(entity.getValue()), entity.getLastModifiedAt());
    }
}
