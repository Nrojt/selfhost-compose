FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    curl git ca-certificates ripgrep fzf && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://opencode.ai/install | bash

RUN git config --system user.name "opencode" && \
    git config --system user.email "opencode@server.local"

WORKDIR /workspace
EXPOSE 4096

CMD ["opencode", "web", "--port", "4096", "--hostname", "0.0.0.0"]
