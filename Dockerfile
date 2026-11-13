FROM eclipse-temurin:22-jdk-jammy@sha256:d8e6ba486df17bf758888d2b1b608133d1eedca8daf69d3fc6bf78d8be81e07e AS build

ARG MAVEN_PROFILE

WORKDIR /workspace

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

RUN chmod +x ./mvnw \
    && if [ -n "$MAVEN_PROFILE" ]; then \
         bash ./mvnw -B -ntp -P"$MAVEN_PROFILE" dependency:go-offline; \
       else \
         bash ./mvnw -B -ntp dependency:go-offline; \
       fi

COPY src/ src/

RUN if [ -n "$MAVEN_PROFILE" ]; then \
      bash ./mvnw -B -ntp -P"$MAVEN_PROFILE" clean package -DskipTests; \
    else \
      bash ./mvnw -B -ntp clean package -DskipTests; \
    fi \
    && jar_file="$(find target -maxdepth 1 -type f -name '*.jar' ! -name '*.jar.original' -print -quit)" \
    && test -n "$jar_file" \
    && cp "$jar_file" /workspace/application.jar

FROM eclipse-temurin:22-jre-jammy@sha256:dbcae8b5dd4d63f81739a538ec2c09797735f04a21d814f9071b62f018326043 AS runtime

RUN apt-get update \
    && apt-get install --yes --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid app --home-dir /app --shell /usr/sbin/nologin app

WORKDIR /app

COPY --from=build --chown=app:app /workspace/application.jar ./application.jar

USER 10001:10001

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl --fail --silent --show-error http://localhost:8080/actuator/health/readiness || exit 1

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-XX:+ExitOnOutOfMemoryError", "-jar", "/app/application.jar"]
