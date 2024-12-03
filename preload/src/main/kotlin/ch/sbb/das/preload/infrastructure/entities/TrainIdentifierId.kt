package ch.sbb.das.preload.infrastructure.entities

import java.io.Serializable
import java.time.LocalDate

class TrainIdentifierId(
    val identifier: String = "",
    val operationDate: LocalDate = LocalDate.now(),
    val ru: String = ""
) : Serializable {

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as TrainIdentifierId

        if (identifier != other.identifier) return false
        if (operationDate != other.operationDate) return false
        if (ru != other.ru) return false

        return true
    }

    override fun hashCode(): Int {
        var result = identifier.hashCode()
        result = 31 * result + operationDate.hashCode()
        result = 31 * result + ru.hashCode()
        return result
    }
}


