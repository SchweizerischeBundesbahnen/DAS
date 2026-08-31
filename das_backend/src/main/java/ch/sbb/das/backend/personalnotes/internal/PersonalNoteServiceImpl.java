package ch.sbb.das.backend.personalnotes.internal;

import ch.sbb.das.backend.personalnotes.PersonalNote;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.json.JsonMapper;

@Service
@RequiredArgsConstructor
class PersonalNoteServiceImpl {

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

    PersonalNote save(String oid, String key, JsonNode value) {
        PersonalNoteEntity entity = personalNoteRepository.findByOidAndKey(oid, key)
            .orElseGet(() -> {
                PersonalNoteEntity newEntity = new PersonalNoteEntity();
                newEntity.setOid(oid);
                newEntity.setKey(key);
                return newEntity;
            });
        entity.setValue(jsonMapper.writeValueAsString(value));
        return toPersonalNote(personalNoteRepository.save(entity));
    }

    private PersonalNote toPersonalNote(PersonalNoteEntity entity) {
        return new PersonalNote(entity.getKey(), jsonMapper.readTree(entity.getValue()), entity.getLastModifiedAt());
    }
}
