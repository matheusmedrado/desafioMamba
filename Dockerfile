# syntax=docker/dockerfile:1

# Builds the release APK without a local Flutter or Android setup.
#
#   docker build --target apk --output type=local,dest=build/docker .
#
# The APK lands in build/docker/app-release.apk.
# Versions are pinned to match .github/workflows/flutter.yml and the
# Android project configuration.

ARG FLUTTER_VERSION=3.47.2
ARG ANDROID_PLATFORM=36
ARG ANDROID_BUILD_TOOLS=36.0.0
ARG ANDROID_NDK=28.2.13676358
ARG CMDLINE_TOOLS=15859902

# ---------------------------------------------------------------------------
# Toolchain: Java 17, Android SDK, Flutter SDK. Cached between source changes.
# ---------------------------------------------------------------------------
FROM eclipse-temurin:17-jdk-jammy AS toolchain

ARG FLUTTER_VERSION
ARG ANDROID_PLATFORM
ARG ANDROID_BUILD_TOOLS
ARG ANDROID_NDK
ARG CMDLINE_TOOLS

ENV ANDROID_HOME=/opt/android-sdk \
    FLUTTER_HOME=/opt/flutter \
    FLUTTER_SUPPRESS_ANALYTICS=true \
    PUB_CACHE=/opt/pub-cache
ENV PATH=$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git unzip xz-utils \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/cmdline-tools.zip \
        "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS}_latest.zip" \
    && mkdir -p "$ANDROID_HOME/cmdline-tools" \
    && unzip -q /tmp/cmdline-tools.zip -d "$ANDROID_HOME/cmdline-tools" \
    && mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" \
    && rm /tmp/cmdline-tools.zip \
    && yes | sdkmanager --licenses > /dev/null \
    && sdkmanager "platform-tools" \
        "platforms;android-${ANDROID_PLATFORM}" \
        "build-tools;${ANDROID_BUILD_TOOLS}" \
        "ndk;${ANDROID_NDK}" > /dev/null

RUN curl -fsSL \
        "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ -C /opt \
    && git config --global --add safe.directory "$FLUTTER_HOME" \
    && flutter config --no-analytics --no-cli-animations > /dev/null \
    && flutter precache --android \
    && flutter --version

# ---------------------------------------------------------------------------
# Build: dependencies first so they are cached while only source changes.
# ---------------------------------------------------------------------------
FROM toolchain AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# The Gradle cache mount keeps plugin and dependency downloads across builds.
RUN --mount=type=cache,target=/root/.gradle \
    flutter build apk --release

# ---------------------------------------------------------------------------
# Output: only the APK, exported to the host with --output.
# ---------------------------------------------------------------------------
FROM scratch AS apk

COPY --from=build /app/build/app/outputs/flutter-apk/app-release.apk /app-release.apk
