# Debian glibc for the Godot binary: official builds are glibc-linked and fail
# under musl's gcompat shim, so they run against a private loader instead.
FROM debian:trixie-slim@sha256:62bd423aeee912639ca8ee681c2b762cb3e25137e0a92b20be455898a9f034ad AS glibc

FROM ghcr.io/anomalyco/opencode:2.1.2@sha256:d91c668b3390b5416fee4803ffd0936ad30c3e118f550e7ad6d2fabc8b974b00

RUN apk add --no-cache \
      bash \
      zsh \
      git \
      openssh-client \
      curl \
      wget \
      ca-certificates \
      jq \
      fzf \
      unzip \
      zip \
      tar \
      nodejs-current \
      npm \
      python3 \
      py3-pip \
      ast-grep \
      github-cli \
      go \
      rust \
      cargo \
      gcc \
      musl-dev \
      gopls \
      rust-analyzer \
      ripgrep \
      fd \
      make \
      yq \
      uv \
      shellcheck \
      sqlite \
      docker-cli \
      docker-cli-compose \
    && git config --system user.name "opencode" && \
    git config --system user.email "opencode@server.local" && \
    git config --system --add credential.https://github.com.helper "gh auth git-credential" && \
    npm install -g --ignore-scripts pnpm oh-my-opencode-slim@3.0.4 @dietrichgebert/ponytail

RUN mkdir -p /usr/lib/jvm/jdk-27 && \
    curl -fsSL https://github.com/adoptium/temurin27-binaries/releases/download/jdk-27%2B35/OpenJDK27U-jdk_x64_alpine-linux_hotspot_27_35.tar.gz | tar xz --strip-components=1 -C /usr/lib/jvm/jdk-27

ENV JAVA_HOME=/usr/lib/jvm/jdk-27

RUN bash -c 'curl -fsSL https://get.sdkman.io | bash && \
    sed -i "s/sdkman_auto_answer=false/sdkman_auto_answer=true/" /root/.sdkman/etc/config && \
    source /root/.sdkman/bin/sdkman-init.sh && \
    sdk install kotlin && \
    sdk install gradle'

ENV PATH="/root/.sdkman/candidates/kotlin/current/bin:/root/.sdkman/candidates/gradle/current/bin:${JAVA_HOME}/bin:${PATH}"

COPY --from=glibc /usr/lib/x86_64-linux-gnu/ /opt/glibc/

RUN mkdir -p /opt/godot && \
    curl -fsSL -o /tmp/godot.zip https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip && \
    unzip -q /tmp/godot.zip -d /opt/godot && rm /tmp/godot.zip && \
    printf '#!/bin/sh\nexec /opt/glibc/ld-linux-x86-64.so.2 --library-path /opt/glibc /opt/godot/Godot_v4.7.2-stable_linux.x86_64 "$@"\n' > /usr/local/bin/godot && \
    chmod +x /usr/local/bin/godot && \
    uv tool install 'gdtoolkit==4.*'

ENV PATH="/root/.local/bin:${PATH}"

RUN git clone --depth 1 https://github.com/mattpocock/skills.git /opt/mattpocock-skills && \
    mkdir -p /root/.config/opencode/skills && \
    for cat in engineering productivity; do \
      for d in /opt/mattpocock-skills/skills/$cat/*/; do \
        [ -f "$d/SKILL.md" ] && ln -s "${d%/}" "/root/.config/opencode/skills/$(basename "$d")"; \
      done; \
    done

RUN oh-my-opencode-slim install --no-tui --preset=openai --companion=no && \
    node -e "const fs=require('fs');const f='/root/.config/opencode/opencode.json';const c=JSON.parse(fs.readFileSync(f,'utf8'));c.plugin=[...new Set([...(c.plugin||[]),'@dietrichgebert/ponytail'])];fs.writeFileSync(f,JSON.stringify(c,null,2))"

RUN cp -a /root/.config/opencode /opt/opencode-config-template

COPY seed-config.sh /usr/local/bin/seed-config.sh
RUN chmod +x /usr/local/bin/seed-config.sh

ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new" \
    OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS=true \
    OPENCODE_ENABLE_EXA=1

WORKDIR /workspace
EXPOSE 4096

ENTRYPOINT ["seed-config.sh"]
CMD ["opencode", "serve", "--port", "4096", "--hostname", "0.0.0.0"]
