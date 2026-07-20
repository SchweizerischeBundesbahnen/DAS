package ch.sbb.das.backend.companies.internal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ch.sbb.das.backend.common.ConflictException;
import ch.sbb.das.backend.companies.Company;
import ch.sbb.das.backend.companies.CompanyCode;
import ch.sbb.das.backend.companies.CompanyShortName;
import ch.sbb.das.backend.companies.Tenant;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class CompanyServiceImplTest {

    private static final String VALID_TENANT_ID = "2cda5d11-f0ac-46b3-967d-af1b2e1bd01a";

    private CompanyRepository companyRepository;
    private TenantRepository tenantRepository;
    private CompanyMapper companyMapper;
    private CompanyServiceImpl underTest;

    private TenantEntity sbbTenant;
    private CompanyEntity companyA;

    @BeforeEach
    void setUp() {
        companyRepository = mock(CompanyRepository.class);
        tenantRepository = mock(TenantRepository.class);
        companyMapper = mock(CompanyMapper.class);
        underTest = new CompanyServiceImpl(companyRepository, tenantRepository, companyMapper);

        sbbTenant = new TenantEntity();
        sbbTenant.setId(1);
        sbbTenant.setName("sbb");
        sbbTenant.setTenantId(VALID_TENANT_ID);
        sbbTenant.setAdminRoleAllowed(true);

        companyA = new CompanyEntity();
        companyA.setId(100);
        companyA.setCode("1111");
        companyA.setShortName("MOCK_A");
        companyA.setTenant(sbbTenant);

        CompanyEntity companyB = new CompanyEntity();
        companyB.setId(101);
        companyB.setCode("2222");
        companyB.setShortName("MOCK_B");
        companyB.setTenant(sbbTenant);

        CompanyEntity companyC = new CompanyEntity();
        companyC.setId(102);
        companyC.setCode("3333");
        companyC.setShortName("MOCK_C");
        companyC.setTenant(sbbTenant);

        sbbTenant.setCompanies(List.of(companyA, companyB, companyC));
    }

    @Test
    void getTenantByIssuerUri() {
        when(tenantRepository.findByTenantId(VALID_TENANT_ID)).thenReturn(Optional.of(sbbTenant));
        Tenant expectedTenant = new Tenant("sbb", VALID_TENANT_ID, true,
            Set.of(new CompanyCode("1111"), new CompanyCode("2222"), new CompanyCode("3333")));
        when(companyMapper.toTenant(sbbTenant)).thenReturn(expectedTenant);

        Tenant tenant = underTest
            .getTenantByIssuerUri("https://login.microsoftonline.com/2cda5d11-f0ac-46b3-967d-af1b2e1bd01a/v2.0");

        assertThat(tenant).isNotNull();
        assertThat(tenant.name()).isEqualTo("sbb");
        assertThat(tenant.isAdminRoleAllowed()).isTrue();
        assertThat(tenant.companies()).containsExactlyInAnyOrder(
            new CompanyCode("1111"), new CompanyCode("2222"), new CompanyCode("3333"));
    }

    @Test
    void getTenantByIssuerUri_badUri() {
        assertThatThrownBy(() -> underTest.getTenantByIssuerUri("https://bad.issuer"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");
    }

    @Test
    void getTenantByIssuerUri_unknownTenant() {
        when(tenantRepository.findByTenantId("unknown-id")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> underTest.getTenantByIssuerUri(
            "https://login.microsoftonline.com/unknown-id/v2.0"))
            .isInstanceOf(IllegalArgumentException.class)
            .hasMessageContaining("unknown tenant");
    }

    @Test
    void findCompanyCodeByShortName() {
        when(companyRepository.findByShortName("MOCK_A")).thenReturn(Optional.of(companyA));

        Optional<CompanyCode> result = underTest.findCompanyCodeByShortName(new CompanyShortName("MOCK_A"));

        assertThat(result).isPresent().contains(new CompanyCode("1111"));
    }

    @Test
    void findCompanyCodeByShortName_notFound() {
        when(companyRepository.findByShortName("NONEXISTENT")).thenReturn(Optional.empty());

        Optional<CompanyCode> result = underTest.findCompanyCodeByShortName(new CompanyShortName("NONEXISTENT"));

        assertThat(result).isEmpty();
    }

    @Test
    void getAllCompanies() {
        Company expectedCompany = new Company(new CompanyCode("1111"), new CompanyShortName("MOCK_A"));
        when(companyRepository.findAll()).thenReturn(List.of(companyA));
        when(companyMapper.toCompany(companyA)).thenReturn(expectedCompany);

        List<Company> companies = underTest.getAllCompanies();

        assertThat(companies).hasSize(1);
        assertThat(companies.getFirst()).isEqualTo(expectedCompany);
    }

    @Test
    void getAllTenants() {
        TenantEntity otherTenant = new TenantEntity();
        otherTenant.setId(2);
        otherTenant.setName("unknown-tenant");
        otherTenant.setTenantId("3409e798-d567-49b1-9bae-f0be66427c54");

        when(tenantRepository.findAll()).thenReturn(List.of(sbbTenant, otherTenant));
        when(companyMapper.toTenantDto(sbbTenant)).thenReturn(new TenantDto("sbb", VALID_TENANT_ID));
        when(companyMapper.toTenantDto(otherTenant)).thenReturn(new TenantDto("unknown-tenant", "3409e798-d567-49b1-9bae-f0be66427c54"));

        List<TenantDto> tenants = underTest.getAllTenants();

        assertThat(tenants).hasSize(2)
            .anyMatch(t -> t.name().equals("sbb") && t.tenantId().equals(VALID_TENANT_ID))
            .anyMatch(t -> t.name().equals("unknown-tenant") && t.tenantId().equals("3409e798-d567-49b1-9bae-f0be66427c54"));
    }

    @Test
    void create_conflict_duplicateCode() {
        when(tenantRepository.findByTenantId(VALID_TENANT_ID)).thenReturn(Optional.of(sbbTenant));
        when(companyRepository.existsByCode("1111")).thenReturn(true);

        CompanyRequest request = new CompanyRequest(new CompanyCode("1111"), new CompanyShortName("UNIQUE"), VALID_TENANT_ID);

        assertThatThrownBy(() -> underTest.create(request))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("Company code already exists");

        verify(companyRepository, never()).save(any());
    }

    @Test
    void create_conflict_duplicateShortName() {
        when(tenantRepository.findByTenantId(VALID_TENANT_ID)).thenReturn(Optional.of(sbbTenant));
        when(companyRepository.existsByCode("NEW1")).thenReturn(false);
        when(companyRepository.existsByShortName("MOCK_A")).thenReturn(true);

        CompanyRequest request = new CompanyRequest(new CompanyCode("NEW1"), new CompanyShortName("MOCK_A"), VALID_TENANT_ID);

        assertThatThrownBy(() -> underTest.create(request))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("Company short name already exists");

        verify(companyRepository, never()).save(any());
    }

    @Test
    void create_success() {
        when(tenantRepository.findByTenantId(VALID_TENANT_ID)).thenReturn(Optional.of(sbbTenant));
        when(companyRepository.existsByCode("9999")).thenReturn(false);
        when(companyRepository.existsByShortName("NEW_CO")).thenReturn(false);

        CompanyEntity newEntity = new CompanyEntity();
        newEntity.setCode("9999");
        newEntity.setShortName("NEW_CO");
        newEntity.setTenant(sbbTenant);
        when(companyMapper.toEntity(any(CompanyRequest.class), eq(sbbTenant))).thenReturn(newEntity);

        CompanyEntity savedEntity = new CompanyEntity();
        savedEntity.setId(200);
        savedEntity.setCode("9999");
        savedEntity.setShortName("NEW_CO");
        savedEntity.setTenant(sbbTenant);
        when(companyRepository.save(newEntity)).thenReturn(savedEntity);

        InternalCompany expectedResult = new InternalCompany(
            200,
            new CompanyCode("9999"),
            new CompanyShortName("NEW_CO"),
            sbbTenant.getTenantId(),
            savedEntity.getLastModifiedAt(),
            savedEntity.getLastModifiedBy()
        );
        when(companyMapper.toAdminCompany(savedEntity)).thenReturn(expectedResult);

        CompanyRequest request = new CompanyRequest(new CompanyCode("9999"), new CompanyShortName("NEW_CO"), VALID_TENANT_ID);
        InternalCompany result = underTest.create(request);

        assertThat(result.id()).isEqualTo(200);
        assertThat(result.code()).isEqualTo(new CompanyCode("9999"));
        assertThat(result.shortName()).isEqualTo(new CompanyShortName("NEW_CO"));
        verify(companyRepository).save(newEntity);
    }

    @Test
    void update_conflict_duplicateCode() {
        CompanyEntity existingEntity = new CompanyEntity();
        existingEntity.setId(900);
        existingEntity.setCode("8881");
        existingEntity.setShortName("EXISTING");
        existingEntity.setTenant(sbbTenant);

        when(companyRepository.findById(900)).thenReturn(Optional.of(existingEntity));
        when(tenantRepository.findByTenantId(VALID_TENANT_ID)).thenReturn(Optional.of(sbbTenant));
        when(companyRepository.existsByCodeAndIdNot("1111", 900)).thenReturn(true);

        CompanyRequest request = new CompanyRequest(new CompanyCode("1111"), new CompanyShortName("UPD1"), VALID_TENANT_ID);

        assertThatThrownBy(() -> underTest.update(900, request))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("Company code already exists");

        verify(companyRepository, never()).save(any());
    }

    @Test
    void update_conflict_duplicateShortName() {
        CompanyEntity existingEntity = new CompanyEntity();
        existingEntity.setId(900);
        existingEntity.setCode("8881");
        existingEntity.setShortName("EXISTING");
        existingEntity.setTenant(sbbTenant);

        when(companyRepository.findById(900)).thenReturn(Optional.of(existingEntity));
        when(tenantRepository.findByTenantId(VALID_TENANT_ID)).thenReturn(Optional.of(sbbTenant));
        when(companyRepository.existsByCodeAndIdNot("8881", 900)).thenReturn(false);
        when(companyRepository.existsByShortNameAndIdNot("MOCK_A", 900)).thenReturn(true);

        CompanyRequest request = new CompanyRequest(new CompanyCode("8881"), new CompanyShortName("MOCK_A"), VALID_TENANT_ID);

        assertThatThrownBy(() -> underTest.update(900, request))
            .isInstanceOf(ConflictException.class)
            .hasMessageContaining("Company short name already exists");

        verify(companyRepository, never()).save(any());
    }

    @Test
    void update_allowsSameCodeForSameEntity() {
        CompanyEntity existingEntity = new CompanyEntity();
        existingEntity.setId(900);
        existingEntity.setCode("8881");
        existingEntity.setShortName("OLD_NAME");
        existingEntity.setTenant(sbbTenant);

        when(companyRepository.findById(900)).thenReturn(Optional.of(existingEntity));
        when(tenantRepository.findByTenantId(VALID_TENANT_ID)).thenReturn(Optional.of(sbbTenant));
        when(companyRepository.existsByCodeAndIdNot("8881", 900)).thenReturn(false);
        when(companyRepository.existsByShortNameAndIdNot("RENAMED", 900)).thenReturn(false);
        when(companyRepository.save(existingEntity)).thenReturn(existingEntity);

        InternalCompany expectedResult = new InternalCompany(
                900,
                new CompanyCode("8881"),
                new CompanyShortName("RENAMED"),
                sbbTenant.getTenantId(),
                existingEntity.getLastModifiedAt(),
                existingEntity.getLastModifiedBy()
        );
        when(companyMapper.toAdminCompany(existingEntity)).thenReturn(expectedResult);

        CompanyRequest request = new CompanyRequest(new CompanyCode("8881"), new CompanyShortName("RENAMED"), VALID_TENANT_ID);
        Optional<InternalCompany> result = underTest.update(900, request);

        assertThat(result).isPresent();
        assertThat(result.get().shortName()).isEqualTo(new CompanyShortName("RENAMED"));
        verify(companyMapper).updateEntity(existingEntity, request, sbbTenant);
        verify(companyRepository).save(existingEntity);
    }

    @Test
    void update_notFound() {
        when(companyRepository.findById(Integer.MAX_VALUE)).thenReturn(Optional.empty());

        CompanyRequest request = new CompanyRequest(new CompanyCode("XXXX"), new CompanyShortName("XXXX"), VALID_TENANT_ID);
        Optional<InternalCompany> result = underTest.update(Integer.MAX_VALUE, request);

        assertThat(result).isEmpty();
    }
}
