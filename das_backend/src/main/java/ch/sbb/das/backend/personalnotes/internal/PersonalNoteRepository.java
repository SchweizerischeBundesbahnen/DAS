package ch.sbb.das.backend.personalnotes.internal;

import java.util.List;
import java.util.Optional;
import org.springframework.data.repository.ListCrudRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PersonalNoteRepository extends ListCrudRepository<PersonalNoteEntity, Integer> {

    List<PersonalNoteEntity> findAllByOid(String oid);

    Optional<PersonalNoteEntity> findByOidAndKey(String oid, String key);
}
