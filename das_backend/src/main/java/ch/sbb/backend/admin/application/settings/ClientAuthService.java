package ch.sbb.backend.admin.application.settings;

import ch.sbb.backend.admin.application.settings.model.response.ClientAuth;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class ClientAuthService {

    @Value("${auth.client.key}")
    private String accessKey;

    @Value("${auth.client.secret}")
    private String accessSecret;

    public ClientAuth getAuth() {
        return new ClientAuth(accessKey, accessSecret);
    }
}
