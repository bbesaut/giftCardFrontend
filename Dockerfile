# syntax=docker/dockerfile:1

# ---- Build stage: compile the Flutter web app ----
FROM debian:bookworm-slim AS build

# Keep in sync with .fvmrc and pubspec.yaml (environment.flutter).
ARG FLUTTER_VERSION=3.47.7
# Backend base URL baked into the bundle at build time (public by nature, never put a secret here).
ARG API_BASE_URL

RUN apt-get update \
    && apt-get install -y --no-install-recommends git curl unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter from its git tag so the toolchain is exactly the pinned version.
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME} \
    && git config --global --add safe.directory ${FLUTTER_HOME} \
    && flutter config --no-analytics --enable-web \
    && flutter precache --web

WORKDIR /app

# Dependencies first: this layer is cached until pubspec.* changes.
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# ---- Runtime stage: static files served by nginx, as a non-root user ----
FROM nginxinc/nginx-unprivileged:stable-alpine AS runtime

# The nginx image renders /etc/nginx/templates/*.template at startup, substituting env vars.
# Render injects its own PORT; 8080 is the default for local runs.
ENV PORT=8080
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
  CMD wget -q --spider http://127.0.0.1:${PORT}/healthz || exit 1
