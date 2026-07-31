package ch.sbb.das.backend.common.config;

import com.zaxxer.hikari.HikariDataSource;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Configuration;
import org.springframework.vault.core.lease.SecretLeaseContainer;
import org.springframework.vault.core.lease.domain.RequestedSecret;
import org.springframework.vault.core.lease.event.SecretLeaseCreatedEvent;
import org.springframework.vault.core.lease.event.SecretLeaseExpiredEvent;

@Configuration
@ConditionalOnBean(SecretLeaseContainer.class)
public class VaultConfig {

    private static final Logger log = LoggerFactory.getLogger(VaultConfig.class);

    private final ConfigurableApplicationContext applicationContext;
    private final HikariDataSource hikariDataSource;
    private final SecretLeaseContainer leaseContainer;
    private final String databasePath;
    private final String databaseRole;

    public VaultConfig(
        ConfigurableApplicationContext applicationContext,
        HikariDataSource hikariDataSource,
        SecretLeaseContainer leaseContainer,
        @Value("${spring.cloud.vault.database.path}") String databasePath,
        @Value("${spring.cloud.vault.database.role}") String databaseRole
    ) {
        this.applicationContext = applicationContext;
        this.hikariDataSource = hikariDataSource;
        this.leaseContainer = leaseContainer;
        this.databasePath = databasePath;
        this.databaseRole = databaseRole;
    }

    @PostConstruct
    private void postConstruct() {
        String vaultCredsPath = this.databasePath + databaseRole;

        leaseContainer.addLeaseListener(event -> {
            if (!vaultCredsPath.equals(event.getSource().getPath())) {
                return;
            }

            log.info("Lease change for DB: ({}) : ({})", event, event.getLease());

            if (event instanceof SecretLeaseExpiredEvent
                && event.getSource().getMode() == RequestedSecret.Mode.RENEW) {

                log.info("Replace RENEW for expired credential with ROTATE");
                leaseContainer.requestRotatingSecret(vaultCredsPath);

            } else if (event instanceof SecretLeaseCreatedEvent createdEvent
                && event.getSource().getMode() == RequestedSecret.Mode.ROTATE) {

                String username = (String) createdEvent.getSecrets().get("username");
                String password = (String) createdEvent.getSecrets().get("password");

                if (username == null || password == null) {
                    log.error("Cannot get updated DB credentials. Shutting down.");
                    applicationContext.close();
                    return;
                }

                refreshDatabaseConnection(username, password);
            }
        });
    }

    private void refreshDatabaseConnection(String username, String password) {
        updateDbProperties(username, password);
        updateDataSource(username, password);
    }

    private void updateDbProperties(String username, String password) {
        System.setProperty("spring.datasource.username", username);
        System.setProperty("spring.datasource.password", password);
    }

    private void updateDataSource(String username, String password) {
        log.info("==> Update database credentials");
        hikariDataSource.getHikariConfigMXBean().setUsername(username);
        hikariDataSource.getHikariConfigMXBean().setPassword(password);

        var poolMXBean = hikariDataSource.getHikariPoolMXBean();
        if (poolMXBean != null) {
            poolMXBean.softEvictConnections();
            log.info("Soft Evict Hikari Data Source Connections");
        } else {
            log.warn("CANNOT Soft Evict Hikari Data Source Connections");
        }
    }
}
