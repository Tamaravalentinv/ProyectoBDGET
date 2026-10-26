FROM eclipse-temurin:17-jdk-jammy@sha256:73ed442231ec66cfe48cae0b263ce619a75ab96d162ab325f38fc0a269ee3aab AS build

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

FROM eclipse-temurin:17-jre-jammy@sha256:b3054a20e1a851574cdb1692dd0db5310c647e62214a2a7abecbec1b9e3ae8f1 AS runtime

RUN groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid app --home-dir /app --shell /usr/sbin/nologin app

WORKDIR /app

COPY --from=build --chown=app:app /workspace/application.jar ./application.jar

USER 10001:10001

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl --fail --silent --show-error http://localhost:8080/students || exit 1

ENTRYPOINT ["java", "-jar", "/app/application.jar"]
