package ch.sbb.backend.preload.infrastructure.entities

import java.io.Serializable
import java.time.LocalDate

class TrainIdentificationId(
    val operationalTrainNumber: String = "",
    val startDate: LocalDate = LocalDate.now(),
    val company: String = ""
) : Serializable {

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as TrainIdentificationId

        if (operationalTrainNumber != other.operationalTrainNumber) return false
        if (startDate != other.startDate) return false
        if (company != other.company) return false

        return true
    }

    override fun hashCode(): Int {
        var result = operationalTrainNumber.hashCode()
        result = 31 * result + startDate.hashCode()
        result = 31 * result + company.hashCode()
        return result
    }
}


