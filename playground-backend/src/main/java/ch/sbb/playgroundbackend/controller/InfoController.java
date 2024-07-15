package ch.sbb.playgroundbackend.controller;

import ch.sbb.playgroundbackend.auth.TenantService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InfoController {

    private final TenantService tenantService;

    public InfoController(TenantService tenantService) {
        this.tenantService = tenantService;
    }

    @GetMapping("/info")
    public String info(@AuthenticationPrincipal Jwt jwt) {
        return String.format("Hello %s from %s!\nThese are your claims:\n%s",
            jwt.getClaimAsString("name"),
            tenantService.getByIssuerUri(jwt.getIssuer().toString()).getName(),
            jwt.getClaims().toString());
    }


    @GetMapping("/admin/info")
    public String admin() {
        return "Welcome admin";
    }


}
