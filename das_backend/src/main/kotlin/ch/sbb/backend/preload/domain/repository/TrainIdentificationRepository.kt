package ch.sbb.backend.preload.domain.repository

import ch.sbb.backend.preload.domain.TrainIdentification

interface TrainIdentificationRepository {
    fun save(trainIdentification: TrainIdentification)
}
