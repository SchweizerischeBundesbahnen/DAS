package ch.sbb.das.backend.features.internal;

import ch.sbb.das.backend.common.ConflictException;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyService;
import ch.sbb.das.backend.features.RuFeature;
import ch.sbb.das.backend.features.RuFeatureService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RuFeatureServiceImpl implements RuFeatureService {

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

    Optional<InternalRuFeature> getById(Integer id) {
        return ruFeatureRepository.findById(id)
                .map(entity -> {
                    companyAuthorizer.requireCanAccessCompanies(Set.of(entity.getCompanyCode()));
                    return entity;
                })
                .map(ruFeatureMapper::toInternalRuFeature);
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

    Optional<InternalRuFeature> update(Integer id, RuFeatureRequest request) {
        Optional<RuFeatureEntity> optional = ruFeatureRepository.findById(id);
        if (optional.isEmpty()) {
            return Optional.empty();
        }
        RuFeatureEntity entity = optional.get();
        companyAuthorizer.requireCanAccessCompanies(Set.of(entity.getCompanyCode()));
        requireCompanyExists(request.companyCode());
        companyAuthorizer.requireCanAccessCompanies(Set.of(request.companyCode()));
        if (ruFeatureRepository.existsByCompanyCodeAndKeyValueAndIdNot(request.companyCode(), request.key().name(), id)) {
            throw new ConflictException("RU feature already exists for company " + request.companyCode().value() + " and key " + request.key());
        }
        ruFeatureMapper.updateEntity(entity, request);
        return Optional.of(ruFeatureMapper.toInternalRuFeature(ruFeatureRepository.save(entity)));
    }

    void delete(Integer id) {
        ruFeatureRepository.findById(id).ifPresent(entity -> {
            companyAuthorizer.requireCanAccessCompanies(Set.of(entity.getCompanyCode()));
            ruFeatureRepository.deleteById(id);
        });
    }

    void deleteAllByIds(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        Set<CompanyCode> companies = ruFeatureRepository.findAllById(distinctIds).stream()
                .map(RuFeatureEntity::getCompanyCode)
                .collect(Collectors.toSet());
        companyAuthorizer.requireCanAccessCompanies(companies);
        ruFeatureRepository.deleteAllById(distinctIds);
    }

    private void requireCompanyExists(CompanyCode companyCode) {
        boolean exists = companyService.getAllCompanies().stream()
                .map(Company::code)
                .anyMatch(companyCode::equals);
        if (!exists) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Company not found: " + companyCode.value());
        }
    }
}
