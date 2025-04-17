package ch.sbb.backend.admin.infrastructure.repositories;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import ch.sbb.backend.JpaAuditingConfiguration;
import ch.sbb.backend.TestcontainersConfiguration;
import ch.sbb.backend.admin.infrastructure.model.RuFeatureEntity;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.jdbc.Sql;

@DataJpaTest
@Import({TestcontainersConfiguration.class, JpaAuditingConfiguration.class})
class SpringDataJpaRuFeatureRepositoryTest {

    @Autowired
    private SpringDataJpaRuFeatureRepository underTest;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    @Sql("classpath:createRuFeature.sql")
    void existingRuFeaturesCanBeFound() {
        RuFeatureEntity entity = underTest.findAll().getFirst();
        assertNotNull(entity);
        assertEquals(1, entity.getId());
        assertEquals("1345", entity.getCompanyCode());
        assertEquals("RUFEATURE", entity.getName());
        assertTrue(entity.getEnabled());
        assertEquals("unit_test", entity.getLastModifiedBy());
        assertEquals(LocalDateTime.parse("2025-04-17T10:18:34"), entity.getLastModifiedAt());
    }

    @Test
    @Sql("classpath:createRuFeature.sql")
    void existingRuFeaturesCanBeUpdated() {

        RuFeatureEntity entityToUpdate = underTest.findAll().getFirst();
        entityToUpdate.setEnabled(false);
        underTest.save(entityToUpdate);

        entityManager.flush();
        RuFeatureEntity entity = entityManager.find(RuFeatureEntity.class, 1);
        assertNotNull(entity);
        assertEquals(1, entity.getId());
        assertEquals("1345", entity.getCompanyCode());
        assertEquals("RUFEATURE", entity.getName());
        assertFalse(entity.getEnabled());
        assertEquals("unit_test", entity.getLastModifiedBy());
        assertTrue(entity.getLastModifiedAt().isAfter(LocalDateTime.parse("2025-04-17T10:18:34")));
    }

    @Test
    @Sql("classpath:createRuFeature.sql")
    void ruFeaturesCanBeCreated() {
        RuFeatureEntity entityToCreate = new RuFeatureEntity();
        entityToCreate.setCompanyCode("1185");
        entityToCreate.setName("FEATURE2");
        entityToCreate.setEnabled(true);
        underTest.save(entityToCreate);
        entityManager.flush();

        RuFeatureEntity entity = entityManager.find(RuFeatureEntity.class, 2);
        assertNotNull(entity);
        assertEquals(2, entity.getId());
        assertEquals("1185", entity.getCompanyCode());
        assertEquals("FEATURE2", entity.getName());
        assertTrue(entity.getEnabled());
        assertEquals("unit_test", entity.getLastModifiedBy());
        assertNotNull(entity.getLastModifiedAt());
    }

    @Test
    @Sql("classpath:createRuFeature.sql")
    void ruFeaturesCanBeDeleted() {
        underTest.deleteById(1);
        entityManager.flush();

        RuFeatureEntity entity = entityManager.find(RuFeatureEntity.class, 1);
        assertNull(entity);
    }
}