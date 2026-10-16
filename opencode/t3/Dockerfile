FROM node:22-bookworm-slim

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
