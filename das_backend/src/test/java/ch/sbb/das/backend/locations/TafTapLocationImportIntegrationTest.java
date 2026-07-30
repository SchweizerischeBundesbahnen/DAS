package ch.sbb.das.backend.locations;

import static ch.sbb.das.backend.locations.internal.TafTapLocationController.API_LOCATIONS;
import static org.hamcrest.Matchers.containsInAnyOrder;
import static org.hamcrest.Matchers.hasSize;
import static org.hamcrest.Matchers.nullValue;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ch.sbb.das.backend.IntegrationTest;
import ch.sbb.das.backend.common.DateTimeUtil;
import ch.sbb.das.backend.locations.internal.ServicePoint;
import ch.sbb.das.backend.locations.internal.ServicePointApiClient;
import ch.sbb.das.backend.locations.internal.TafTapLocationsImportService;
import java.time.LocalDate;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.web.servlet.MockMvc;

@IntegrationTest
@Sql("classpath:emptyTafTapLocations.sql")
class TafTapLocationImportIntegrationTest {

    @Autowired
    private TafTapLocationsImportService tafTapLocationsImportService;
    @Autowired
    private MockMvc mockMvc;
    @MockitoBean
    private ServicePointApiClient servicePointApiClient;

    @DisplayName("TafTap location import when the cronjob runs then locations are imported and updated|tests:538,155")
    @Test
    @WithMockUser(authorities = "ROLE_admin")
    void cronjob_importsAndUpdate() throws Exception {
        LocalDate validTo = LocalDate.parse("9999-12-31");
        LocalDate sp3ValidFrom = DateTimeUtil.today().plusMonths(10);
        ServicePoint sp1 = new ServicePoint("Service Point 1", "SP1", DateTimeUtil.today(), validTo, new ServicePoint.ServicePointNumber(12345, 98));
        ServicePoint sp2 = new ServicePoint("Service Point 2", "SP2", DateTimeUtil.today().minusYears(2), validTo, new ServicePoint.ServicePointNumber(56789, 76));
        ServicePoint sp3 = new ServicePoint("Future Service Point 3", "SP3", sp3ValidFrom, validTo, new ServicePoint.ServicePointNumber(555, 54));
        ServicePoint sp4 = new ServicePoint("More Future Service Point 4", "SP4", DateTimeUtil.today().plusYears(2), validTo, new ServicePoint.ServicePointNumber(11111, 32));
        when(servicePointApiClient.getAll()).thenReturn(List.of(sp1, sp2, sp3, sp4));
        tafTapLocationsImportService.importLocations();
        mockMvc.perform(get(API_LOCATIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(3)))
            .andExpect(jsonPath("$.data[*].locationReference", containsInAnyOrder("LB12345", "NO56789", "CZ00555")))
            .andExpect(jsonPath("$.data[*].primaryLocationName", containsInAnyOrder("Service Point 1", "Service Point 2", "Future Service Point 3")))
            .andExpect(jsonPath("$.data[*].locationAbbreviation", containsInAnyOrder("SP1", "SP2", "SP3")))
            .andExpect(jsonPath("$.data[*].validFrom", containsInAnyOrder(null, null, sp3ValidFrom.toString())));

        // second import
        LocalDate sp2v2ValidFrom = DateTimeUtil.today().plusDays(10);
        ServicePoint sp2v1 = new ServicePoint("Service Point 2", "SP2", DateTimeUtil.today().minusYears(2), DateTimeUtil.today().plusDays(10), new ServicePoint.ServicePointNumber(56789, 76));
        ServicePoint sp2v2 = new ServicePoint("Service Point 2", "SP2", sp2v2ValidFrom, validTo, new ServicePoint.ServicePointNumber(56789, 76));
        when(servicePointApiClient.getAll()).thenReturn(List.of(sp1, sp2v1, sp2v2, sp3));
        tafTapLocationsImportService.importLocations();
        mockMvc.perform(get(API_LOCATIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(4)))
            .andExpect(jsonPath("$.data[*].locationReference", containsInAnyOrder("LB12345", "NO56789", "NO56789", "CZ00555")))
            .andExpect(jsonPath("$.data[*].primaryLocationName", containsInAnyOrder("Service Point 1", "Service Point 2", "Service Point 2", "Future Service Point 3")))
            .andExpect(jsonPath("$.data[*].locationAbbreviation", containsInAnyOrder("SP1", "SP2", "SP2", "SP3")))
            .andExpect(jsonPath("$.data[*].validFrom", containsInAnyOrder(null, null, sp2v2ValidFrom.toString(), sp3ValidFrom.toString())));
    }

    @DisplayName("TafTap location import when the cronjob runs then locations without diff are merge imported|tests:538,155")
    @Test
    @WithMockUser(authorities = "ROLE_admin")
    void cronjob_importsNoDuplicate() throws Exception {
        LocalDate dateOfChange = DateTimeUtil.today().plusDays(100);
        ServicePoint sp1 = new ServicePoint("Service Point 1", "SP1", DateTimeUtil.today(), dateOfChange, new ServicePoint.ServicePointNumber(12345, 98));
        ServicePoint sp2 = new ServicePoint("Service Point 1", "SP1", dateOfChange.plusDays(1), LocalDate.parse("9999-12-31"), new ServicePoint.ServicePointNumber(12345, 98));

        when(servicePointApiClient.getAll()).thenReturn(List.of(sp1, sp2));
        tafTapLocationsImportService.importLocations();
        mockMvc.perform(get(API_LOCATIONS))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.data", hasSize(1)))
            .andExpect(jsonPath("$.data[0].locationReference").value("LB12345"))
            .andExpect(jsonPath("$.data[0].primaryLocationName").value("Service Point 1"))
            .andExpect(jsonPath("$.data[0].locationAbbreviation").value("SP1"))
            .andExpect(jsonPath("$.data[0].validFrom", nullValue()));
    }
}
