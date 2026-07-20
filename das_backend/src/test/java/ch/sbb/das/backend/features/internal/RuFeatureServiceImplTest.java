package ch.sbb.das.backend.features.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.common.ConflictException;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.features.RuFeature;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.server.ResponseStatusException;

class RuFeatureServiceImplTest {

    private static final CompanyCode COMPANY_1111 = new CompanyCode("1111");
    private static final CompanyCode COMPANY_9999 = new CompanyCode("9999");

    private RuFeatureRepository ruFeatureRepository;
    private RuFeatureMapper ruFeatureMapper;
    private CompanyAuthorizer companyAuthorizer;
    private CompanyService companyService;
    private RuFeatureServiceImpl underTest;

    @BeforeEach
    void setUp() {
        ruFeatureRepository = mock(RuFeatureRepository.class);
        ruFeatureMapper = mock(RuFeatureMapper.class);
        companyAuthorizer = mock(CompanyAuthorizer.class);
        companyService = mock(CompanyService.class);
        underTest = new RuFeatureServiceImpl(ruFeatureRepository, ruFeatureMapper, companyAuthorizer, companyService);

        when(companyService.getAllCompanies()).thenReturn(List.of(
            new Company(COMPANY_1111, new CompanyShortName("MOCK_A")),
            new Company(COMPANY_9999, new CompanyShortName("MOCK_OTHER"))));
    }

    private RuFeatureEntity entity(Integer id, CompanyCode companyCode, String key, boolean enabled) {
        RuFeatureEntity entity = new RuFeatureEntity();
        entity.setId(id);
        entity.setCompanyCode(companyCode);
        entity.setKeyValue(key);
        entity.setEnabled(enabled);
        return entity;
    }

    @Test
    void shouldGetAllRuFeatures() {
        RuFeatureEntity ruFeatureEntity = entity(1, COMPANY_1111, "CUSTOMER_ORIENTED_DEPARTURE_PROCESS", true);
        RuFeature expectedRuFeature = new RuFeature(COMPANY_1111, COMPANY_1111, "CUSTOMER_ORIENTED_DEPARTURE_PROCESS", true);

        when(ruFeatureRepository.findAll()).thenReturn(List.of(ruFeatureEntity));
        when(ruFeatureMapper.toRuFeature(ruFeatureEntity)).thenReturn(expectedRuFeature);

        List<RuFeature> actualRuFeatures = underTest.getAll();
        assertThat(actualRuFeatures).isEqualTo(List.of(expectedRuFeature));
    }

    @Test
    void getAllForAdmin_filtersByAuthorizedCompanies() {
        RuFeatureEntity ownEntity = entity(1, COMPANY_1111, "WARNAPP", true);
        RuFeatureEntity otherEntity = entity(2, COMPANY_9999, "WARNAPP", true);
        InternalRuFeature ownFeature = new InternalRuFeature(1, COMPANY_1111, "WARNAPP", true, null, null);

        when(ruFeatureRepository.findAll()).thenReturn(List.of(ownEntity, otherEntity));
        when(companyAuthorizer.authorizedCompanies()).thenReturn(Set.of(COMPANY_1111));
        when(ruFeatureMapper.toInternalRuFeature(ownEntity)).thenReturn(ownFeature);

        List<InternalRuFeature> result = underTest.getAllForAdmin();

        assertThat(result).containsExactly(ownFeature);
    }

    @Test
    void getById_ok() {
        RuFeatureEntity entity = entity(1, COMPANY_1111, "WARNAPP", true);
        InternalRuFeature expected = new InternalRuFeature(1, COMPANY_1111, "WARNAPP", true, null, null);
        when(ruFeatureRepository.findById(1)).thenReturn(Optional.of(entity));
        when(ruFeatureMapper.toInternalRuFeature(entity)).thenReturn(expected);

        Optional<InternalRuFeature> result = underTest.getById(1);

        assertThat(result).contains(expected);
        verify(companyAuthorizer).requireCanAccessCompanies(Set.of(COMPANY_1111));
    }

    @Test
    void getById_notFound() {
        when(ruFeatureRepository.findById(99)).thenReturn(Optional.empty());

        assertThat(underTest.getById(99)).isEmpty();
    }

    @Test
    void getById_forbidden() {
        RuFeatureEntity entity = entity(3, COMPANY_9999, "WARNAPP", true);
        when(ruFeatureRepository.findById(3)).thenReturn(Optional.of(entity));
        doThrow(new AccessDeniedException("Not allowed")).when(companyAuthorizer).requireCanAccessCompanies(Set.of(COMPANY_9999));

        assertThatThrownBy(() -> underTest.getById(3)).isInstanceOf(AccessDeniedException.class);
    }

    @Test
    void create_ok() {
        RuFeatureRequest request = new RuFeatureRequest(COMPANY_1111, RuFeatureKey.WARNAPP, true);
        RuFeatureEntity newEntity = entity(null, COMPANY_1111, "WARNAPP", true);
        RuFeatureEntity savedEntity = entity(10, COMPANY_1111, "WARNAPP", true);
        InternalRuFeature expected = new InternalRuFeature(10, COMPANY_1111, "WARNAPP", true, null, null);

        when(ruFeatureRepository.existsByCompanyCodeAndKeyValue(COMPANY_1111, "WARNAPP")).thenReturn(false);
        when(ruFeatureMapper.toEntity(request)).thenReturn(newEntity);
        when(ruFeatureRepository.save(newEntity)).thenReturn(savedEntity);
        when(ruFeatureMapper.toInternalRuFeature(savedEntity)).thenReturn(expected);

        InternalRuFeature result = underTest.create(request);

        assertThat(result).isEqualTo(expected);
        verify(companyAuthorizer).requireCanAccessCompanies(Set.of(COMPANY_1111));
    }

    @Test
    void create_badRequest_companyNotFound() {
        RuFeatureRequest request = new RuFeatureRequest(new CompanyCode("ZZZZ"), RuFeatureKey.WARNAPP, true);

        assertThatThrownBy(() -> underTest.create(request))
            .isInstanceOf(ResponseStatusException.class)
            .hasMessageContaining("Company not found");

        verify(ruFeatureRepository, never()).save(any());
    }

    @Test
    void create_forbidden_unauthorizedCompany() {
        RuFeatureRequest request = new RuFeatureRequest(COMPANY_9999, RuFeatureKey.WARNAPP, true);
        doThrow(new AccessDeniedException("Not allowed")).when(companyAuthorizer).requireCanAccessCompanies(Set.of(COMPANY_9999));

        assertThatThrownBy(() -> underTest.create(request)).isInstanceOf(AccessDeniedException.class);

        verify(ruFeatureRepository, never()).save(any());
    }

    @Test
    void create_conflict_duplicate() {
        RuFeatureRequest request = new RuFeatureRequest(COMPANY_1111, RuFeatureKey.WARNAPP, true);
        when(ruFeatureRepository.existsByCompanyCodeAndKeyValue(COMPANY_1111, "WARNAPP")).thenReturn(true);

        assertThatThrownBy(() -> underTest.create(request))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("already exists");

        verify(ruFeatureRepository, never()).save(any());
    }

    @Test
    void update_ok() {
        RuFeatureEntity existingEntity = entity(1, COMPANY_1111, "WARNAPP", false);
        RuFeatureRequest request = new RuFeatureRequest(COMPANY_1111, RuFeatureKey.WARNAPP, true);
        InternalRuFeature expected = new InternalRuFeature(1, COMPANY_1111, "WARNAPP", true, null, null);

        when(ruFeatureRepository.findById(1)).thenReturn(Optional.of(existingEntity));
        when(ruFeatureRepository.existsByCompanyCodeAndKeyValueAndIdNot(COMPANY_1111, "WARNAPP", 1)).thenReturn(false);
        when(ruFeatureRepository.save(existingEntity)).thenReturn(existingEntity);
        when(ruFeatureMapper.toInternalRuFeature(existingEntity)).thenReturn(expected);

        Optional<InternalRuFeature> result = underTest.update(1, request);

        assertThat(result).contains(expected);
        verify(ruFeatureMapper).updateEntity(existingEntity, request);
    }

    @Test
    void update_notFound() {
        when(ruFeatureRepository.findById(99)).thenReturn(Optional.empty());

        assertThat(underTest.update(99, new RuFeatureRequest(COMPANY_1111, RuFeatureKey.WARNAPP, true))).isEmpty();
        verify(ruFeatureRepository, never()).save(any());
    }

    @Test
    void update_forbidden_existingCompanyNotAuthorized() {
        RuFeatureEntity existingEntity = entity(3, COMPANY_9999, "WARNAPP", true);
        when(ruFeatureRepository.findById(3)).thenReturn(Optional.of(existingEntity));
        doThrow(new AccessDeniedException("Not allowed")).when(companyAuthorizer).requireCanAccessCompanies(Set.of(COMPANY_9999));

        assertThatThrownBy(() -> underTest.update(3, new RuFeatureRequest(COMPANY_9999, RuFeatureKey.WARNAPP, true)))
            .isInstanceOf(AccessDeniedException.class);

        verify(ruFeatureRepository, never()).save(any());
    }

    @Test
    void update_forbidden_movingToUnauthorizedCompany() {
        RuFeatureEntity existingEntity = entity(1, COMPANY_1111, "WARNAPP", true);
        when(ruFeatureRepository.findById(1)).thenReturn(Optional.of(existingEntity));
        doThrow(new AccessDeniedException("Not allowed")).when(companyAuthorizer).requireCanAccessCompanies(eq(Set.of(COMPANY_9999)));

        assertThatThrownBy(() -> underTest.update(1, new RuFeatureRequest(COMPANY_9999, RuFeatureKey.WARNAPP, true)))
            .isInstanceOf(AccessDeniedException.class);

        verify(ruFeatureRepository, never()).save(any());
    }

    @Test
    void update_badRequest_companyNotFound() {
        RuFeatureEntity existingEntity = entity(1, COMPANY_1111, "WARNAPP", true);
        when(ruFeatureRepository.findById(1)).thenReturn(Optional.of(existingEntity));

        assertThatThrownBy(() -> underTest.update(1, new RuFeatureRequest(new CompanyCode("ZZZZ"), RuFeatureKey.WARNAPP, true)))
            .isInstanceOf(ResponseStatusException.class)
            .hasMessageContaining("Company not found");

        verify(ruFeatureRepository, never()).save(any());
    }

    @Test
    void update_conflict_duplicate() {
        RuFeatureEntity existingEntity = entity(1, COMPANY_1111, "WARNAPP", true);
        when(ruFeatureRepository.findById(1)).thenReturn(Optional.of(existingEntity));
        when(ruFeatureRepository.existsByCompanyCodeAndKeyValueAndIdNot(COMPANY_1111, "CHECKLIST_DEPARTURE_PROCESS", 1)).thenReturn(true);

        assertThatThrownBy(() -> underTest.update(1, new RuFeatureRequest(COMPANY_1111, RuFeatureKey.CHECKLIST_DEPARTURE_PROCESS, true)))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("already exists");

        verify(ruFeatureRepository, never()).save(any());
    }

    @Test
    void deleteAllByIds_ok() {
        RuFeatureEntity entity1 = entity(1, COMPANY_1111, "WARNAPP", true);
        RuFeatureEntity entity2 = entity(2, COMPANY_1111, "CHECKLIST_DEPARTURE_PROCESS", false);
        when(ruFeatureRepository.findAllById(List.of(1, 2))).thenReturn(List.of(entity1, entity2));

        underTest.deleteAllByIds(List.of(1, 2));

        verify(companyAuthorizer).requireCanAccessCompanies(Set.of(COMPANY_1111));
        verify(ruFeatureRepository).deleteAllById(List.of(1, 2));
    }

    @Test
    void deleteAllByIds_forbidden_mixedCompanies() {
        RuFeatureEntity ownEntity = entity(1, COMPANY_1111, "WARNAPP", true);
        RuFeatureEntity otherEntity = entity(3, COMPANY_9999, "WARNAPP", true);
        when(ruFeatureRepository.findAllById(List.of(1, 3))).thenReturn(List.of(ownEntity, otherEntity));
        doThrow(new AccessDeniedException("Not allowed")).when(companyAuthorizer).requireCanAccessCompanies(Set.of(COMPANY_1111, COMPANY_9999));

        assertThatThrownBy(() -> underTest.deleteAllByIds(List.of(1, 3))).isInstanceOf(AccessDeniedException.class);

        verify(ruFeatureRepository, never()).deleteAllById(any());
    }
}
