package ch.sbb.backend.preload.infrastructure;

import ch.sbb.backend.preload.application.mapper.TrainRunMapper;
import ch.sbb.backend.preload.application.model.dailytrainrun.Train;
import com.fasterxml.jackson.core.JsonProcessingException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import lombok.extern.slf4j.Slf4j;
import lombok.val;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class TrainRunDAO {

    private final NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    private final JdbcTemplate jdbcTemplate;

    private final TrainRunMapper trainRunMapper;

    public TrainRunDAO(NamedParameterJdbcTemplate namedParameterJdbcTemplate, JdbcTemplate jdbcTemplate, TrainRunMapper trainRunMapper) {
        this.namedParameterJdbcTemplate = namedParameterJdbcTemplate;
        this.jdbcTemplate = jdbcTemplate;
        this.trainRunMapper = trainRunMapper;
    }

    public void deleteAllTrains(List<Train> trains) {
        deleteAllTrainsFromTable("train", trains);
    }

    public void upsertAllTrains(List<Train> trains) {
        String sql = """
            merge into train
            using (
               select
                    CAST(:pathId as varchar) as path_id,
                    CAST(:period as int) as period,
                    CAST(:trainNumber as varchar) as train_number,
                    CAST(:infrastructureNet as varchar) as infrastructure_net,
                    CAST(:orderingRu as varchar) as ordering_ru
            ) as source
            on (train.path_id = source.path_id and train.period = source.period)
            when not matched then
                insert (path_id, period, train_number, infrastructure_net, ordering_ru)
                values (source.path_id, source.period, source.train_number, source.infrastructure_net, source.ordering_ru)
            when matched then
                update set train_number = source.train_number, infrastructure_net = source.infrastructure_net, ordering_ru = source.ordering_ru
            """;
        MapSqlParameterSource[] params = trains.stream().map(train -> {
            MapSqlParameterSource paramValues = new MapSqlParameterSource();
            paramValues.addValue("pathId", train.getPathId());
            paramValues.addValue("period", train.getPeriod());
            paramValues.addValue("trainNumber", train.getTrainNumber());
            paramValues.addValue("infrastructureNet", train.getInfrastructureNet());
            paramValues.addValue("orderingRu", train.getOrderingRU());
            return paramValues;
        }).toArray(MapSqlParameterSource[]::new);
        int[] rowsUpdated = namedParameterJdbcTemplate.batchUpdate(sql, params);
        log.debug("{} rows of table train updated", Arrays.stream(rowsUpdated).sum());
    }

    public void deleteAllFromTrainRun(List<Train> trains) {
        deleteAllTrainsFromTable("train_run", trains);
    }

    public void deleteAllFromTrainRunDays(List<Train> trains) {
        deleteAllTrainsFromTable("train_run_dates", trains);
    }

    public void insertTrainRuns(List<Train> trains) throws JsonProcessingException {
        String sql = """
            insert into train_run
                (path_id, period, train_run_id, train_run_points, sms_rus)
                values (:pathId, :period, :trainRunId, :trainRunPoints, :smsRus)
            """;
        val params = new ArrayList<MapSqlParameterSource>();
        for (val train : trains) {
            for (int trainRunId = 0; trainRunId < train.getTrainRuns().size(); trainRunId++) {
                val trainRun = train.getTrainRuns().get(trainRunId);
                MapSqlParameterSource paramValues = new MapSqlParameterSource();
                paramValues.addValue("pathId", train.getPathId());
                paramValues.addValue("period", train.getPeriod());
                paramValues.addValue("trainRunId", trainRunId);
                paramValues.addValue("trainRunPoints", trainRunMapper.toEntity(trainRun.getTrainRunPoints()));
                paramValues.addValue("smsRus", String.join(",", trainRun.getSmsRUs()));
                params.add(paramValues);
            }
        }

        MapSqlParameterSource[] sqlParams = params.toArray(MapSqlParameterSource[]::new);
        int[] rowsInserted = namedParameterJdbcTemplate.batchUpdate(sql, sqlParams);
        log.debug("{} rows to table train_run inserted", Arrays.stream(rowsInserted).sum());
    }

    public void insertTrainRunDays(List<Train> trains) {
        String sql = """
            insert into train_run_dates
                (path_id, period, operational_date, start_date, train_run_id)
                values (:pathId, :period, :operationalDate, :startDate, :trainRunId)
            """;
        val params = new ArrayList<MapSqlParameterSource>();
        for (val train : trains) {
            for (int trainRunId = 0; trainRunId < train.getTrainRuns().size(); trainRunId++) {
                val trainRun = train.getTrainRuns().get(trainRunId);

                for (int i = 0; i < trainRun.getTrainRunDates().size(); i++) {
                    MapSqlParameterSource paramValues = new MapSqlParameterSource();
                    paramValues.addValue("pathId", train.getPathId());
                    paramValues.addValue("period", train.getPeriod());
                    paramValues.addValue("operationalDate", trainRun.getTrainRunDates().get(i).getOperationalDate());
                    paramValues.addValue("startDate", trainRun.getTrainRunDates().get(i).getStartDate());
                    paramValues.addValue("trainRunId", trainRunId);
                    params.add(paramValues);
                }
            }
        }

        MapSqlParameterSource[] sqlParams = params.toArray(MapSqlParameterSource[]::new);
        int[] rowsInserted = namedParameterJdbcTemplate.batchUpdate(sql, sqlParams);
        log.debug("{} rows to table train_run_dates inserted", Arrays.stream(rowsInserted).sum());
    }

    public void deleteAllTrainRunsOlderThan(LocalDate date) {
        deleteAllFromTrainRunDatesOlderThan(date);
        deleteUnreferencedTrainRuns();
    }

    public void deleteTrainsWithPeriodOlderThan(int period) {
        String sql = """
            delete from train
            where period < :period
            """;
        MapSqlParameterSource paramValue = new MapSqlParameterSource();
        paramValue.addValue("period", period);
        int rowsDeleted = namedParameterJdbcTemplate.update(sql, paramValue);
        log.info("{} of old rows of train with period < {} were deleted", rowsDeleted, period);
    }

    public void deleteAllData() {
        truncateTable("train");
        truncateTable("train_run");
        truncateTable("train_run_dates");
    }

    private void deleteAllFromTrainRunDatesOlderThan(LocalDate date) {
        String sql = """
            delete from train_run_dates
            where start_date < :date
            """;
        MapSqlParameterSource paramValue = new MapSqlParameterSource();
        paramValue.addValue("date", date);
        int rowsDeleted = namedParameterJdbcTemplate.update(sql, paramValue);
        log.info("{} of old rows of train_run_dates with date < {} were deleted", rowsDeleted, date);
    }

    private void deleteUnreferencedTrainRuns() {
        String sql = """
            delete from train_run
            where not exists (
                select * from train_run_dates
                 where train_run_dates.path_id = train_run.path_id
                   and train_run_dates.period = train_run.period)
            """;
        int rowsDeleted = jdbcTemplate.update(sql);
        log.info("{} unreferenced rows of train_run deleted", rowsDeleted);
    }

    private void deleteAllTrainsFromTable(String tableName, List<Train> trains) {
        String sql = """
            delete from %s
            where path_id = :pathId and period = :period
            """.formatted(tableName);
        MapSqlParameterSource[] params = trains.stream().map(train -> {
            MapSqlParameterSource paramValues = new MapSqlParameterSource();
            paramValues.addValue("pathId", train.getPathId());
            paramValues.addValue("period", train.getPeriod());
            return paramValues;
        }).toArray(MapSqlParameterSource[]::new);
        int[] rowsDeleted = namedParameterJdbcTemplate.batchUpdate(sql, params);
        log.debug("{} rows of table {} deleted", Arrays.stream(rowsDeleted).sum(), tableName);
    }

    private void truncateTable(String tableName) {
        jdbcTemplate.execute("truncate table " + tableName);
        log.info("table {} was truncated", tableName);
    }
}
