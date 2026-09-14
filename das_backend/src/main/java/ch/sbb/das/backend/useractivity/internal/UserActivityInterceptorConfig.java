package ch.sbb.das.backend.useractivity.internal;

import static ch.sbb.das.backend.personalnotes.internal.PersonalNoteController.API_PERSONAL_NOTES;
import static ch.sbb.das.backend.userproperties.internal.UserPropertyController.API_USER_PROPERTIES;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@RequiredArgsConstructor
class UserActivityInterceptorConfig implements WebMvcConfigurer {

    private final UserActivityInterceptor userActivityInterceptor;

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(userActivityInterceptor)
            .addPathPatterns(
                API_PERSONAL_NOTES + "/**",
                API_USER_PROPERTIES + "/**");
    }
}
