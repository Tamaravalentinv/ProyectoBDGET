FROM eclipse-temurin:17-jdk-jammy@sha256:73ed442231ec66cfe48cae0b263ce619a75ab96d162ab325f38fc0a269ee3aab AS build

ARG MAVEN_PROFILE

WORKDIR /workspace

COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

RUN chmod +x ./mvnw \
    && for attempt in 1 2 3; do \
         if [ -n "$MAVEN_PROFILE" ]; then \
           bash ./mvnw -B -ntp -P"$MAVEN_PROFILE" dependency:go-offline && break; \
         else \
           bash ./mvnw -B -ntp dependency:go-offline && break; \
         fi; \
         if [ "$attempt" -eq 3 ]; then \
           echo "ERROR: Maven dependency resolution failed after 3 attempts"; \
           exit 1; \
         fi; \
         echo "Maven download failed. Retrying in 20 seconds..."; \
         sleep 20; \
       done

COPY src/ src/

RUN if [ -n "$MAVEN_PROFILE" ]; then \
      bash ./mvnw -B -ntp -P"$MAVEN_PROFILE" clean package -DskipTests; \
    else \
      bash ./mvnw -B -ntp clean package -DskipTests; \
    fi \
    && jar_file="$(find target -maxdepth 1 -type f -name '*.jar' ! -name '*.jar.original' -print -quit)" \
    && test -n "$jar_file" \
    && cp "$jar_file" /workspace/application.jar

FROM eclipse-temurin:17-jre-jammy@sha256:b3054a20e1a851574cdb1692dd0db5310c647e62214a2a7abecbec1b9e3ae8f1 AS runtime

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
