package ch.sbb.sferamock.messages.services;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDate;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

@Slf4j
@Service
public class FormationsService {

    @Value("${db.url}")
    private String url;

    @Value("${db.user}")
    private String user;

    @Value("${db.password}")
    private String password;

    @FunctionalInterface
    private interface StatementParameters {

        void set(PreparedStatement stmt) throws SQLException;
    }

    private int executeSql(String sqlFile, StatementParameters parameters) throws IOException {
        File resource = new ClassPathResource("sql/" + sqlFile).getFile();
        String sql = new String(Files.readAllBytes(resource.toPath()));
        try (Connection conn = DriverManager.getConnection(url, user, password);
            PreparedStatement stmt = conn.prepareStatement(sql)) {
            parameters.set(stmt);
            return stmt.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    public void initialState(String operationalTrainNumber, LocalDate operationalDay, String companyCode) throws IOException {
        delete(operationalTrainNumber, operationalDay, companyCode);
        insert(operationalTrainNumber, operationalDay, companyCode);
    }

    public void updatedState(String operationalTrainNumber, LocalDate operationalDay, String companyCode) throws IOException {
        update(operationalTrainNumber, operationalDay, companyCode);
    }

    private void delete(String operationalTrainNumber, LocalDate operationalDay, String companyCode) throws IOException {
        int affectedRows = executeSql("delete.sql", stmt -> {
            stmt.setString(1, operationalTrainNumber);
            stmt.setDate(2, Date.valueOf(operationalDay));
            stmt.setString(3, companyCode);
        });
        log.info("Deleted {} rows", affectedRows);
    }

    private void insert(String operationalTrainNumber, LocalDate operationalDay, String companyCode) throws IOException {
        int affectedRows = executeSql("insert.sql", stmt -> {
            // 1st formation
            stmt.setString(1, operationalTrainNumber);
            stmt.setDate(2, Date.valueOf(operationalDay));
            stmt.setString(3, companyCode);
            // 2nd formation
            stmt.setString(4, operationalTrainNumber);
            stmt.setDate(5, Date.valueOf(operationalDay));
            stmt.setString(6, companyCode);
        });
        log.info("Created {} rows", affectedRows);
    }

    private void update(String operationalTrainNumber, LocalDate operationalDay, String companyCode) throws IOException {
        int affectedRows = executeSql("update.sql", stmt -> {
            stmt.setString(1, operationalTrainNumber);
            stmt.setDate(2, Date.valueOf(operationalDay));
            stmt.setString(3, companyCode);
        });
        log.info("Updated {} rows", affectedRows);
    }
}
