FROM eclipse-temurin:25-jdk-jammy@sha256:07a4ee373cd86f337e62cb8149f1e0a9f08aaf3a18c27509a493dda119fb480c AS build

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

FROM eclipse-temurin:25-jre-jammy@sha256:e0d8c47eccd7ec82d635542dfcd1f2b1293add6bdd7ffbeb650f8ec1b1335425 AS runtime

RUN groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid app --home-dir /app --shell /usr/sbin/nologin app

WORKDIR /app

COPY --from=build --chown=app:app /workspace/application.jar ./application.jar

USER 10001:10001

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=40s --retries=3 \
    CMD curl --fail --silent --show-error http://localhost:8080/students || exit 1

ENTRYPOINT ["java", "-jar", "/app/application.jar"]
