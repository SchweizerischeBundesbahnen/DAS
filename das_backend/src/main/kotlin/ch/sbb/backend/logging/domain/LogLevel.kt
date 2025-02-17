package ch.sbb.backend.logging.domain

data class LogLevel(val value: String) {
    companion object {
        val TRACE = LogLevel("TRACE")
        val DEBUG = LogLevel("DEBUG")
        val INFO = LogLevel("INFO")
        val WARNING = LogLevel("WARNING")
        val ERROR = LogLevel("ERROR")
        val FATAL = LogLevel("FATAL")
    }
}
