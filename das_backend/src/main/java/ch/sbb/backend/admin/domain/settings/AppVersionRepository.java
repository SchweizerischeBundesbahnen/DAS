package ch.sbb.backend.admin.domain.settings;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppVersionRepository extends JpaRepository<AppVersion, Long> {

    List<AppVersion> findAll();
}
