package ch.sbb.das.backend.appversions;

public interface AppVersionService {

    CurrentAppVersion getCurrent(String version);
}
