package ch.sbb.das.backend.indications.internal;

import ch.sbb.das.backend.companies.CompanyAuthorizer;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.indications.internal.model.RuIndication;
import ch.sbb.das.backend.indications.internal.model.RuIndicationRequest;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class RuIndicationServiceImpl {

    private final RuIndicationRepository ruIndicationRepository;
    private final CompanyAuthorizer companyAuthorizationService;
    private final RuIndicationMapper ruIndicationMapper;

    public List<RuIndication> getAll() {
        Set<CompanyCode> authorizedCompanies = companyAuthorizationService.authorizedCompanies();
        return ruIndicationRepository.findAll().stream()
            .filter(ruIndication -> ruIndication.getCompanies() != null && authorizedCompanies.containsAll(ruIndication.getCompanies()))
            .map(ruIndicationMapper::toResponse)
            .toList();
    }

    public RuIndication getById(Integer id) {
        return ruIndicationRepository.findById(id)
            .map(ruIndication -> {
                companyAuthorizationService.requireCanAccessCompanies(ruIndication.getCompanies());
                return ruIndication;
            })
            .map(ruIndicationMapper::toResponse)
            .orElse(null);
    }

    public RuIndication create(RuIndicationRequest createRequest) {
        companyAuthorizationService.requireCanAccessCompanies(createRequest.scope().companies());
        RuIndicationEntity entity = ruIndicationMapper.toEntityFromRequest(null, createRequest);
        return ruIndicationMapper.toResponse(ruIndicationRepository.save(entity));
    }

    public RuIndication update(Integer id, RuIndicationRequest updateRequest) {
        RuIndicationEntity existingRuIndication = ruIndicationRepository.findById(id).orElse(null);
        if (existingRuIndication == null) {
            return null;
        }
        companyAuthorizationService.requireCanAccessCompanies(existingRuIndication.getCompanies());
        companyAuthorizationService.requireCanAccessCompanies(updateRequest.scope().companies());
        RuIndicationEntity entity = ruIndicationMapper.toEntityFromRequest(id, updateRequest);
        return ruIndicationMapper.toResponse(ruIndicationRepository.save(entity));
    }

    public void delete(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        Set<CompanyCode> companies = ruIndicationRepository.findAllById(distinctIds).stream()
            .flatMap(ruIndication -> ruIndication.getCompanies().stream())
            .collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        ruIndicationRepository.deleteAllById(distinctIds);
    }

    public void deleteAllBefore(LocalDate localDate) {
        ruIndicationRepository.deleteAllByLastPeriodBefore(localDate);
    }
}
