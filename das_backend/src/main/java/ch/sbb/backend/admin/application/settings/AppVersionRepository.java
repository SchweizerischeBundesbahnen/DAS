package ch.sbb.backend.admin.application.settings;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppVersionRepository extends JpaRepository<AppVersion, Long> {

    List<AppVersion> findAll();
}
