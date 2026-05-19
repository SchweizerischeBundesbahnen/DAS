package ch.sbb.das.backend.admin.domain.notices;

import ch.sbb.das.backend.admin.application.notices.model.Notice;
import ch.sbb.das.backend.admin.application.notices.model.NoticeRequest;
import ch.sbb.das.backend.common.CompanyCode;
import ch.sbb.das.backend.tenancy.infrastructure.CompanyAuthorizer;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class NoticeServiceImpl implements NoticeService {

    private final NoticeRepository noticeRepository;
    private final CompanyAuthorizer companyAuthorizationService;

    public NoticeServiceImpl(NoticeRepository noticeRepository, CompanyAuthorizer companyAuthorizationService) {
        this.noticeRepository = noticeRepository;
        this.companyAuthorizationService = companyAuthorizationService;
    }

    @Override
    public List<Notice> getAll() {
        Set<CompanyCode> authorizedCompanies = companyAuthorizationService.authorizedCompanies();
        return noticeRepository.findAll().stream()
            .filter(notice -> notice.scope() != null && notice.scope().companies() != null && authorizedCompanies.containsAll(notice.scope().companies()))
            .toList();
    }

    @Override
    public Notice getById(Integer id) {
        return noticeRepository.findById(id)
            .map(notice -> {
                companyAuthorizationService.requireCanAccessCompanies(notice.scope().companies());
                return notice;
            })
            .orElse(null);
    }

    @Override
    public Notice create(NoticeRequest createRequest) {
        companyAuthorizationService.requireCanAccessCompanies(createRequest.scope().companies());
        Notice created = new Notice(null, createRequest.content(), createRequest.scope(), createRequest.periods());
        return noticeRepository.save(created);
    }

    @Override
    public Notice update(Integer id, NoticeRequest updateRequest) {
        Notice existingNotice = noticeRepository.findById(id).orElse(null);
        if (existingNotice == null) {
            return null;
        }
        companyAuthorizationService.requireCanAccessCompanies(existingNotice.scope().companies());
        companyAuthorizationService.requireCanAccessCompanies(updateRequest.scope().companies());
        Notice updated = new Notice(id, updateRequest.content(), updateRequest.scope(), updateRequest.periods());
        return noticeRepository.save(updated);
    }

    @Override
    public void delete(Integer id) {
        noticeRepository.findById(id).ifPresent(notice -> {
            companyAuthorizationService.requireCanAccessCompanies(notice.scope().companies());
            noticeRepository.deleteById(id);
        });
    }

    @Override
    public void delete(List<Integer> ids) {
        List<Integer> distinctIds = ids.stream().distinct().toList();
        Set<CompanyCode> companies = noticeRepository.findAllById(distinctIds).stream()
            .flatMap(notice -> notice.scope().companies().stream())
            .collect(Collectors.toSet());
        companyAuthorizationService.requireCanAccessCompanies(companies);
        noticeRepository.deleteAllById(distinctIds);
    }
}
