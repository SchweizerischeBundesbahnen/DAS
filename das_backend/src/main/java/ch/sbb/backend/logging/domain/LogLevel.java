package ch.sbb.backend.logging.domain;

public record LogLevel(String value) {

    public static final LogLevel TRACE = new LogLevel("TRACE");
    public static final LogLevel DEBUG = new LogLevel("DEBUG");
    public static final LogLevel INFO = new LogLevel("INFO");
    public static final LogLevel WARNING = new LogLevel("WARNING");
    public static final LogLevel ERROR = new LogLevel("ERROR");
    public static final LogLevel FATAL = new LogLevel("FATAL");
}