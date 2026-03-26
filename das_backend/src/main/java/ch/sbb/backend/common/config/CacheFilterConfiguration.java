package ch.sbb.backend.common.config;

import ch.sbb.backend.admin.application.locations.LocationController;
import ch.sbb.backend.formation.api.v1.FormationController;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.filter.ShallowEtagHeaderFilter;

@Configuration
public class CacheFilterConfiguration {

    @Bean
    public FilterRegistrationBean<ShallowEtagHeaderFilter> shallowEtagHeaderFilter() {
        FilterRegistrationBean<ShallowEtagHeaderFilter> filterRegistrationBean
            = new FilterRegistrationBean<>(new ShallowEtagHeaderFilter());
        filterRegistrationBean.addUrlPatterns(FormationController.API_FORMATIONS, LocationController.API_LOCATIONS);
        filterRegistrationBean.setName("shallowEtagHeaderFilter");
        return filterRegistrationBean;
    }
}
