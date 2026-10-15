FROM ghcr.io/anomalyco/opencode:2.0.29

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
