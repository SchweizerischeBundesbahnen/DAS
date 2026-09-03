package ch.sbb.das.backend.personalnotes.internal;

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
class PersonalNoteServiceImpl {

    static final int MAX_VALUE_LENGTH = 16384;

    private final PersonalNoteRepository personalNoteRepository;
    private final JsonMapper jsonMapper;

    List<PersonalNote> getAllByOid(String oid) {
        return personalNoteRepository.findAllByOid(oid).stream()
            .map(this::toPersonalNote)
            .toList();
    }

    Optional<PersonalNote> getByOidAndKey(String oid, String key) {
        return personalNoteRepository.findByOidAndKey(oid, key)
            .map(this::toPersonalNote);
    }

    @Transactional
    PersonalNote save(String oid, String key, JsonNode value) {
        String serializedValue = jsonMapper.writeValueAsString(value);
        if (serializedValue.length() > MAX_VALUE_LENGTH) {
            throw new ResponseStatusException(HttpStatus.CONTENT_TOO_LARGE,
                "Personal note value exceeds the maximum allowed length of " + MAX_VALUE_LENGTH + " characters.");
        }
        PersonalNoteEntity entity = personalNoteRepository.findByOidAndKey(oid, key)
            .orElseGet(() -> {
                PersonalNoteEntity newEntity = new PersonalNoteEntity();
                newEntity.setOid(oid);
                newEntity.setKey(key);
                return newEntity;
            });
        entity.setValue(serializedValue);
        return toPersonalNote(personalNoteRepository.save(entity));
    }

    @Transactional
    void delete(String oid, String key) {
        personalNoteRepository.deleteByOidAndKey(oid, key);
    }

    private PersonalNote toPersonalNote(PersonalNoteEntity entity) {
        return new PersonalNote(entity.getKey(), jsonMapper.readTree(entity.getValue()), entity.getLastModifiedAt());
    }
}
