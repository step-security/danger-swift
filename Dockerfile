ARG SWIFT_VERSION=5.9
FROM swift:${SWIFT_VERSION}-focal

LABEL org.opencontainers.image.authors="Orta Therox"

LABEL "com.github.actions.name"="Danger Swift"
LABEL "com.github.actions.description"="Runs Swift Dangerfiles"
LABEL "com.github.actions.icon"="zap"
LABEL "com.github.actions.color"="blue"

# Install nodejs and Danger
RUN apt-get update -q \
    && apt-get install -qy curl make ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -qy nodejs \
    && npm install -g danger \
    && rm -r /var/lib/apt/lists/*


RUN curl -L -o swiftlint.zip https://github.com/realm/SwiftLint/releases/download/0.65.1/swiftlint_linux_amd64.zip && echo "caeed6f4a679c35539ffaf124f6c4ab4a8416917f7d8796279dc52b74026059d  swiftlint.zip" | sha256sum -c - && unzip swiftlint.zip -d swiftlint && mv swiftlint/swiftlint /usr/local/bin/swiftlint && chmod +x /usr/local/bin/swiftlint && rm -rf swiftlint swiftlint.zip  # swiftlint:0.65.1

# Install danger-swift globally
COPY . _danger-swift
RUN cd _danger-swift && make install && rm -rf _danger-swift

# Run Danger Swift via Danger JS, allowing for custom args
ENTRYPOINT ["danger-swift", "ci"]
