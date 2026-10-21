FROM node:24-bookworm-slim@sha256:55fb5f5a527ea2c5c4a95f963e48ef90aa38c7b346054fdc8ee9957a2b55d205

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libatomic1 \
      ca-certificates \
      git \
      curl \
      openssh-client && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g t3 @opencode/cli && \
    git config --system user.name "opencode" && \
    git config --system user.email "opencode@server.local"

ENV GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new"

WORKDIR /workspace
EXPOSE 3773

CMD ["t3", "serve", "--mode", "web", "--host", "0.0.0.0", "--port", "3773"]
