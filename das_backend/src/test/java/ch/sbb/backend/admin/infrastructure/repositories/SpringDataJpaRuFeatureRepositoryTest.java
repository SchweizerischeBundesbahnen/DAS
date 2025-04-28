package ch.sbb.backend.admin.infrastructure.repositories;

import static ch.sbb.backend.admin.domain.settings.model.RuFeatureName.GESTES;
import static org.assertj.core.api.Assertions.assertThat;

import ch.sbb.backend.JpaAuditingConfiguration;
import ch.sbb.backend.TestContainerConfiguration;
import ch.sbb.backend.admin.domain.settings.model.RuFeatureName;
import ch.sbb.backend.admin.infrastructure.settings.SpringDataJpaRuFeatureRepository;
import ch.sbb.backend.admin.infrastructure.settings.model.CompanyEntity;
import ch.sbb.backend.admin.infrastructure.settings.model.RuFeatureEntity;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.jdbc.Sql;

@DataJpaTest
@Import({TestContainerConfiguration.class, JpaAuditingConfiguration.class})
class SpringDataJpaRuFeatureRepositoryTest {

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
        assertThat(entity.getName()).isEqualTo(GESTES.name());
        assertThat(entity.isEnabled()).isTrue();
        assertThat(entity.getLastModifiedBy()).isEqualTo("unit_test");
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

        assertThat(entity.getName()).isEqualTo(RuFeatureName.GESTES.name());
        assertThat(entity.isEnabled()).isFalse();
        assertThat(entity.getLastModifiedBy()).isEqualTo("unit_test");
        assertThat(entity.getLastModifiedAt()).isAfter(LocalDateTime.parse("2025-04-17T10:18:34"));
    }

    @Test
    @Sql("classpath:createRuFeature.sql")
    void ruFeaturesCanBeCreated() {
        CompanyEntity company = entityManager.find(CompanyEntity.class, 2);
        RuFeatureEntity entityToCreate = new RuFeatureEntity();
        entityToCreate.setCompany(company);
        entityToCreate.setName("FEATURE2");
        entityToCreate.setEnabled(true);
        underTest.save(entityToCreate);
        entityManager.flush();

        RuFeatureEntity entity = entityManager.find(RuFeatureEntity.class, 2);
        assertThat(entity).isNotNull();
        assertThat(entity.getId()).isEqualTo(2);
        assertThat(entity.getCompany().getCodeRics()).isEqualTo("2222");
        assertThat(entity.getCompany().getShortNameZis()).isEqualTo("SHORT2");
        assertThat(entity.getName()).isEqualTo("FEATURE2");
        assertThat(entity.isEnabled()).isTrue();
        assertThat(entity.getLastModifiedBy()).isEqualTo("unit_test");
        assertThat(entity.getLastModifiedAt()).isNotNull();
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