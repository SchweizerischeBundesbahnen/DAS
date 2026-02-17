package ch.sbb.backend.preload.infrastructure;

import ch.sbb.backend.preload.application.converter.TimeConverter;
import ch.sbb.backend.preload.application.model.trainidentification.Train;
import ch.sbb.backend.preload.application.model.trainidentification.TrainRun;
import ch.sbb.backend.preload.application.model.trainidentification.TrainRunDate;
import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TrainRunDAO {

    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    public TrainRunDAO(NamedParameterJdbcTemplate namedParameterJdbcTemplate) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
    }

    public void upsertAllTrains(List<Train> trains) {
        String sql = """
            merge into train_identification
            using (
               select
                    CAST(:trainPathId as text) as train_path_id,
                    CAST(:period as int) as period,
                    CAST(:operationalTrainNumber as text) as operational_train_number,
                    CAST(:companies as text) as companies,
                    CAST(:startDateTime as timestamp with time zone) as start_date_time,
                    CAST(:operationalDay as date) as operational_day
            ) as source
            on (train_identification.train_path_id = source.train_path_id and train_identification.period = source.period and train_identification.operational_day = source.operational_day)
            when not matched then
                insert (id, train_path_id, period, operational_train_number, companies, start_date_time, operational_day)
                values (nextval('train_identification_id_seq'), source.train_path_id, source.period, source.operational_train_number, source.companies, source.start_date_time, source.operational_day)
            when matched then
                update set companies = source.companies, start_date_time = source.start_date_time
            """;
        val params = new ArrayList<MapSqlParameterSource>();

        for (val train : trains) {
            for (TrainRun trainRun : train.getTrainRuns()) {
                for (TrainRunDate trainRunDate : trainRun.getTrainRunDates()) {
                    MapSqlParameterSource paramValues = new MapSqlParameterSource();
                    paramValues.addValue("trainPathId", train.getTrainPathId());
                    paramValues.addValue("period", train.getPeriod());
                    paramValues.addValue("operationalTrainNumber", train.getOperationalTrainNumber());
                    paramValues.addValue("companies", String.join(",", trainRun.getCompanies()));
                    paramValues.addValue("startDateTime", toStartDateTime(trainRunDate, trainRun));
                    paramValues.addValue("operationalDay", trainRunDate.getOperationalDate());
                    params.add(paramValues);
                }
            }
        }
        MapSqlParameterSource[] sqlParams = params.toArray(MapSqlParameterSource[]::new);
        int[] rowsUpdated = namedParameterJdbcTemplate.batchUpdate(sql, sqlParams);
        log.debug("{} rows of table train updated", Arrays.stream(rowsUpdated).sum());
    }

    private OffsetDateTime toStartDateTime(TrainRunDate trainRunDate, TrainRun trainRun) {
        return TimeConverter.convertTime(trainRunDate.getOperationalDate(), trainRun.getFirstDepartureTime());
    }

    public void deleteAllOlderThan(LocalDate date) {
        String sql = """
            delete from train_identification
            where start_date_time < :date
            """;
        MapSqlParameterSource paramValue = new MapSqlParameterSource();
        paramValue.addValue("date", date);
        int rowsDeleted = namedParameterJdbcTemplate.update(sql, paramValue);
        log.info("{} of old rows of train_run_dates with date < {} were deleted", rowsDeleted, date);
    }

    public void deleteAll(List<Train> trains) {
        String sql = """
            delete from train_identification
            where train_path_id = :trainPathId and period = :period
            """;
        MapSqlParameterSource[] params = trains.stream().map(train -> {
            MapSqlParameterSource paramValues = new MapSqlParameterSource();
            paramValues.addValue("trainPathId", train.getTrainPathId());
            paramValues.addValue("period", train.getPeriod());
            return paramValues;
        }).toArray(MapSqlParameterSource[]::new);
        int[] rowsDeleted = namedParameterJdbcTemplate.batchUpdate(sql, params);
        log.debug("{} rows of train_identification table deleted", Arrays.stream(rowsDeleted).sum());
    }
}
