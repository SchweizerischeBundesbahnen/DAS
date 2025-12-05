package ch.sbb.backend.admin.infrastructure.settings;

import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.AuditorAwareTestImpl;
import ch.sbb.backend.JpaAuditingConfiguration;
import ch.sbb.backend.PersistenceH2TestProfile;
import ch.sbb.backend.admin.domain.settings.model.RuFeatureKey;
import ch.sbb.backend.admin.infrastructure.settings.model.CompanyEntity;
import ch.sbb.backend.admin.infrastructure.settings.model.RuFeatureEntity;
import java.time.LocalDateTime;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.jpa.test.autoconfigure.TestEntityManager;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.jdbc.Sql;

/**
 * H2 clone for {@link SpringDataJpaRuFeatureRepositoryTest}
 */
@PersistenceH2TestProfile
@Import({JpaAuditingConfiguration.class})
class SpringDataJpaRuFeatureRepositoryH2Test {

    @Autowired
    private SpringDataJpaRuFeatureRepository underTest;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    @Sql("classpath:createRuFeature.sql")
    void existingRuFeaturesCanBeFound() {
        RuFeatureEntity entity = underTest.findAll().getFirst();
        assertThat(entity).isNotNull();
        assertThat(entity.getId()).isEqualTo(1);
        assertThat(entity.getCompany().getCodeRics()).isEqualTo("1111");
        assertThat(entity.getCompany().getShortNameZis()).isEqualTo("SHORT1");
        assertThat(entity.getKeyValue()).isEqualTo(RuFeatureKey.CHECKLIST_DEPARTURE_PROCESS.name());
        assertThat(entity.isEnabled()).isTrue();
        assertThat(entity.getLastModifiedBy()).as("JpaAuditing introduced").isEqualTo(AuditorAwareTestImpl.LAST_MODIFIED_BY);
        assertThat(entity.getLastModifiedAt()).isEqualTo(LocalDateTime.parse("2025-04-17T10:18:34"));
    }

    @Test
    @Sql("classpath:createRuFeature.sql")
    void existingRuFeaturesCanBeUpdated() {
        RuFeatureEntity entityToUpdate = underTest.findAll().getFirst();
        entityToUpdate.setEnabled(false);
        underTest.save(entityToUpdate);

        entityManager.flush();
        RuFeatureEntity entity = entityManager.find(RuFeatureEntity.class, 1);
        assertThat(entity).isNotNull();
        assertThat(entity.getId()).isEqualTo(1);
        assertThat(entity.getCompany().getCodeRics()).isEqualTo("1111");
        assertThat(entity.getCompany().getShortNameZis()).isEqualTo("SHORT1");

        assertThat(entity.getKeyValue()).isEqualTo(RuFeatureKey.CHECKLIST_DEPARTURE_PROCESS.name());
        assertThat(entity.isEnabled()).isFalse();
        assertThat(entity.getLastModifiedBy()).as("JpaAuditing introduced").isEqualTo(AuditorAwareTestImpl.LAST_MODIFIED_BY);
        assertThat(entity.getLastModifiedAt()).isAfter(LocalDateTime.parse("2025-04-17T10:18:34"));
    }

    @Test
    @Sql("classpath:createRuFeature.sql")
    void ruFeaturesCanBeCreated() {
        CompanyEntity company = entityManager.find(CompanyEntity.class, 2);

        RuFeatureEntity entityToCreate = new RuFeatureEntity();
        entityToCreate.setCompany(company);
        entityToCreate.setKeyValue("FEATURE2");
        entityToCreate.setEnabled(true);
        underTest.save(entityToCreate);
        entityManager.flush();

        RuFeatureEntity entity = entityManager.find(RuFeatureEntity.class, 2);
        assertThat(entity).isNotNull();
        assertThat(entity.getId()).as("next free sequence").isEqualTo(2);
        assertThat(entity.getCompany().getId()).as("sequence").isEqualTo(2);
        assertThat(entity.getCompany().getCodeRics()).isEqualTo("2222");
        assertThat(entity.getCompany().getShortNameZis()).isEqualTo("SHORT2");
        assertThat(entity.getKeyValue()).isEqualTo("FEATURE2");
        assertThat(entity.isEnabled()).isTrue();
        assertThat(entity.getLastModifiedBy()).as("JpaAuditing introduced").isEqualTo(AuditorAwareTestImpl.LAST_MODIFIED_BY);
        assertThat(entity.getLastModifiedAt()).isNotNull();

        List<RuFeatureEntity> entities = underTest.findAll();
        assertThat(entities.getLast()).isEqualTo(entityToCreate);
    }

    @Test
    @Sql("classpath:createRuFeature.sql")
    void ruFeaturesCanBeDeleted() {
        underTest.deleteById(1);
        entityManager.flush();

        RuFeatureEntity entity = entityManager.find(RuFeatureEntity.class, 1);
        assertThat(entity).isNull();
    }
}
