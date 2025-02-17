package ch.sbb.backend.common

import jakarta.servlet.http.HttpServletRequest
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.slf4j.event.Level
import org.springframework.http.HttpHeaders
import org.springframework.util.StopWatch

class RequestLogger(
    private val stopWatch: StopWatch,
    private val level: Level
) {
    private val LOGGER: Logger = LoggerFactory.getLogger(RequestLogger::class.java)

    fun log(request: HttpServletRequest?, httpStatusCode: Int?) {
        stopWatch.stop()
        val params = request?.parameterMap?.map { (key, value) -> "$key:${value.joinToString(",")}" }?.joinToString("&")
        val loggingEventBuilder = LOGGER.atLevel(level)

        loggingEventBuilder.log("Request path=${request?.requestURI}, " +
                    "requestId=${request?.requestId}, " +
                    "method=${request?.method}, " +
                    "query=${params}, " +
                    "user_agent=${request?.getHeader(HttpHeaders.USER_AGENT)}, " +
                    "responseStatusCode=${httpStatusCode}, " +
                    "runTimeMs=${stopWatch.totalTimeMillis}")
    }

    companion object {
        fun from(request: HttpServletRequest): RequestLogger {
            val level = if (request.requestURI.startsWith("/actuator")) Level.DEBUG else Level.INFO
            val stopWatch = StopWatch()
            stopWatch.start()
            return RequestLogger(stopWatch, level)
        }
    }
}
