# Stage 1: Build the .jar file
FROM gradle:8.0.2-jdk17 AS builder
WORKDIR /app
COPY stirling-pdf /app/stirling-pdf
WORKDIR /app/stirling-pdf
RUN gradle build --no-daemon

# Stage 2: Final image
FROM alpine:3.22.0

# Install runtime dependencies
RUN echo "@main https://dl-cdn.alpinelinux.org/alpine/edge/main" | tee -a /etc/apk/repositories && \
    apk add --no-cache openjdk17 tzdata bash tini ca-certificates && \
    addgroup -S stirlingpdfgroup && adduser -S stirlingpdfuser -G stirlingpdfgroup && \
    mkdir -p /app && chown -R stirlingpdfuser:stirlingpdfgroup /app

USER stirlingpdfuser
WORKDIR /app

# Copy built .jar from builder stage
COPY --from=builder /app/stirling-pdf/build/libs/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["tini", "--"]
CMD ["java", "-jar", "app.jar"]