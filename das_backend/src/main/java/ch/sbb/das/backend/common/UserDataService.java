package ch.sbb.das.backend.common;

import java.util.List;

/**
 * Contract implemented by every module that stores personal, user-owned data (e.g. personal notes, user properties). It exposes the bulk deletion used by the user-data clean-up so that a single
 * scheduler can remove all data of inactive users without depending on the internals of each module.
 */
public interface UserDataService {

    /**
     * Deletes all data owned by the given users.
     *
     * @param oids the object ids of the users whose data must be removed, never {@code null}
     * @return the number of deleted records
     */
    int deleteAllByOids(List<String> oids);
}
