package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.common.error.BadRequestException;
import ch.sbb.das.backend.common.error.ConflictException;
import ch.sbb.das.backend.common.error.NotFoundException;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.features.RuFeature;
import ch.sbb.das.backend.features.RuFeatureService;
import java.util.List;
import java.util.Set;
import java.util.function.Predicate;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class RuFeatureServiceImpl implements RuFeatureService {

    private static final String RESOURCE = "RU feature";

    private final RuFeatureRepository ruFeatureRepository;
    private final RuFeatureMapper ruFeatureMapper;
    private final CompanyAuthorizer companyAuthorizer;
    private final CompanyService companyService;

    @Override
    public List<RuFeature> getAll() {
        return ruFeatureRepository.findAll().stream()
            .map(ruFeatureMapper::toRuFeature)
            .toList();
    }

    List<InternalRuFeature> getAllForAdmin() {
        Set<CompanyCode> authorizedCompanies = companyAuthorizer.authorizedCompanies();
        return ruFeatureRepository.findAll().stream()
            .filter(entity -> authorizedCompanies.contains(entity.getCompanyCode()))
            .map(ruFeatureMapper::toInternalRuFeature)
            .toList();
    }

    /**
     * Returns the RU feature with the given id as the current tenant sees it.
     *
     * @throws NotFoundException when no RU feature with that id exists or it belongs to a company the current tenant may not access
     */
    InternalRuFeature getById(Integer id) {
        return ruFeatureMapper.toInternalRuFeature(findAccessibleById(id));
    }

    InternalRuFeature create(RuFeatureRequest request) {
        requireCompanyExists(request.companyCode());
        companyAuthorizer.requireCanAccessCompanies(Set.of(request.companyCode()));
        if (ruFeatureRepository.existsByCompanyCodeAndKeyValue(request.companyCode(), request.key().name())) {
            throw new ConflictException("RU feature already exists for company " + request.companyCode().value() + " and key " + request.key());
        }
        RuFeatureEntity entity = ruFeatureMapper.toEntity(request);
        return ruFeatureMapper.toInternalRuFeature(ruFeatureRepository.save(entity));
    }

    /**
     * Updates the RU feature with the given id as the current tenant sees it.
     *
     * @throws NotFoundException see {@link #getById(Integer)}
     */
    InternalRuFeature update(Integer id, RuFeatureRequest request) {
        RuFeatureEntity entity = findAccessibleById(id);
        requireCompanyExists(request.companyCode());
        companyAuthorizer.requireCanAccessCompanies(Set.of(request.companyCode()));
        if (ruFeatureRepository.existsByCompanyCodeAndKeyValueAndIdNot(request.companyCode(), request.key().name(), id)) {
            throw new ConflictException("RU feature already exists for company " + request.companyCode().value() + " and key " + request.key());
        }
        ruFeatureMapper.updateEntity(entity, request);
        return ruFeatureMapper.toInternalRuFeature(ruFeatureRepository.save(entity));
    }

    /**
     * Deletes the accessible RU features among the given ids; unknown ids and ids of other tenants' RU features are skipped alike.
     */
    void deleteAllByIds(List<Integer> ids) {
        Predicate<Set<CompanyCode>> canAccessCompanies = companyAuthorizer.companyAccessCheck(); // resolves the tenant once for the whole batch
        List<Integer> accessibleIds = ruFeatureRepository.findAllById(ids.stream().distinct().toList()).stream()
            .filter(entity -> canAccess(entity, canAccessCompanies))
            .map(RuFeatureEntity::getId)
            .toList();
        ruFeatureRepository.deleteAllById(accessibleIds);
    }

    private RuFeatureEntity findAccessibleById(Integer id) {
        return ruFeatureRepository.findById(id)
            .filter(this::canAccess)
            .orElseThrow(() -> NotFoundException.forId(RESOURCE, id));
    }

    /**
     * Existing entities of other tenants are treated like missing ones so that ids cannot be probed; the log keeps the denial visible.
     */
    private boolean canAccess(RuFeatureEntity entity) {
        return canAccess(entity, companyAuthorizer::canAccessCompanies);
    }

    private boolean canAccess(RuFeatureEntity entity, Predicate<Set<CompanyCode>> canAccessCompanies) {
        if (canAccessCompanies.test(Set.of(entity.getCompanyCode()))) {
            return true;
        }
        log.info("{} {} belongs to a company outside the current tenant, treating it as not found", RESOURCE, entity.getId());
        return false;
    }

    private void requireCompanyExists(CompanyCode companyCode) {
        boolean exists = companyService.getAllCompanies().stream()
            .map(Company::code)
            .anyMatch(companyCode::equals);
        if (!exists) {
            throw new BadRequestException("Company not found: " + companyCode.value());
        }
    }
}
