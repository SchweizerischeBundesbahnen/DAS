package ch.sbb.das.backend.useractivity;

/**
 * Tracks the last time each user (identified by {@code oid}) accessed personal data such as personal notes or user properties. This information is used to clean up data belonging to users who have
 * been inactive for a configurable amount of time.
 */
public interface UserActivityService {

    /**
     * Records that the user identified by {@code oid} accessed their personal data now.
     *
     * @param oid the object id of the user, must not be {@code null} or blank
     */
    void recordAccess(String oid);
}
