# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /build

COPY pom.xml .
RUN mvn -B dependency:go-offline

COPY src ./src
RUN mvn -B clean package -DskipTests

# Some repositories read static_sfera_resources via ClassPathResource#getFile(), which only
# resolves for resources that exist as real files on disk, not inside a packaged jar. Extract
# the jar here (JDK image has `jar`) so the runtime stage can run off a plain classpath.
RUN mkdir -p /build/unpacked \
    && cd /build/unpacked \
    && jar xf /build/target/sfera_mock-*.jar

# ---- Runtime stage ----
FROM eclipse-temurin:25-jre AS runtime
WORKDIR /app

RUN addgroup --system sfera-mock && adduser --system --home /home/sfera-mock --ingroup sfera-mock sfera-mock
ENV HOME=/home/sfera-mock
USER sfera-mock:sfera-mock

COPY --from=build /build/unpacked/BOOT-INF/classes ./classes
COPY --from=build /build/unpacked/BOOT-INF/lib ./lib

EXPOSE 8081

ENTRYPOINT ["java", "-cp", "classes:lib/*", "ch.sbb.sferamock.SferaMockApplication"]
