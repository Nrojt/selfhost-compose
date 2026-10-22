# Debian glibc for the Godot binary: official builds are glibc-linked and fail
# under musl's gcompat shim, so they run against a private loader instead.
FROM debian:trixie-slim@sha256:62bd423aeee912639ca8ee681c2b762cb3e25137e0a92b20be455898a9f034ad AS glibc

FROM ghcr.io/anomalyco/opencode:2.1.2@sha256:d91c668b3390b5416fee4803ffd0936ad30c3e118f550e7ad6d2fabc8b974b00

# Renovate bumps this via the customManager in renovate.json (github-releases).
ARG GODOT_VERSION=4.7.2-stable

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
      py3-numpy \
      py3-opencv \
      py3-pillow \
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
      socat \
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
    curl -fsSL -o /tmp/godot.zip "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip" && \
    unzip -q /tmp/godot.zip -d /opt/godot && rm /tmp/godot.zip && \
    printf '#!/bin/sh\nexec /opt/glibc/ld-linux-x86-64.so.2 --library-path /opt/glibc /opt/godot/Godot_v%s_linux.x86_64 "$@"\n' "${GODOT_VERSION}" > /usr/local/bin/godot && \
    chmod +x /usr/local/bin/godot && \
    uv tool install 'gdtoolkit==4.*'

# Godot's language server is TCP-only; opencode spawns LSPs on stdio. This
# wrapper boots a headless editor for the project, then bridges stdio to it.
COPY <<'EOF' /usr/local/bin/godot-lsp
#!/bin/sh
PORT=$((6005 + $$ % 2000))
godot --headless --editor --path "${PWD:-.}" --lsp-port "$PORT" >/dev/null 2>&1 &
GODOT_PID=$!
trap 'kill "$GODOT_PID" 2>/dev/null' EXIT
i=0
until socat -u OPEN:/dev/null TCP:127.0.0.1:"$PORT" 2>/dev/null; do
  i=$((i + 1))
  [ "$i" -ge 120 ] && echo "godot-lsp: editor did not open port $PORT" >&2 && exit 1
  sleep 1
done
exec socat STDIO TCP:127.0.0.1:"$PORT"
EOF
RUN chmod +x /usr/local/bin/godot-lsp && \
    npm install -g @coding-solo/godot-mcp@0.1.1

ENV PATH="/root/.local/bin:${PATH}"

RUN git clone --depth 1 https://github.com/mattpocock/skills.git /opt/mattpocock-skills && \
    mkdir -p /root/.config/opencode/skills && \
    for cat in engineering productivity; do \
      for d in /opt/mattpocock-skills/skills/$cat/*/; do \
        [ -f "$d/SKILL.md" ] && ln -s "${d%/}" "/root/.config/opencode/skills/$(basename "$d")"; \
      done; \
    done

RUN oh-my-opencode-slim install --no-tui --preset=openai --companion=no && \
    node -e "const fs=require('fs');const f='/root/.config/opencode/opencode.json';const c=JSON.parse(fs.readFileSync(f,'utf8'));c.plugin=[...new Set([...(c.plugin||[]),'@dietrichgebert/ponytail'])];c.mcp={...(c.mcp||{}),servers:{...(c.mcp&&c.mcp.servers||{}),godot:{type:'local',command:['godot-mcp'],environment:{GODOT_PATH:'/usr/local/bin/godot'}}}};c.lsp={...(c.lsp||{}),gdscript:{command:['/usr/local/bin/godot-lsp'],extensions:['.gd']}};fs.writeFileSync(f,JSON.stringify(c,null,2))"

COPY <<'EOF' /root/.config/opencode/skills/godot/SKILL.md
---
name: Godot
description: Work on Godot 4 projects headlessly - import assets, run scenes, validate and format GDScript, use the godot MCP tools and the GDScript LSP. Use when the project has project.godot, *.gd, *.tscn files or a .godot directory.
---

## Tools in this container

- `godot` - Godot 4.7.x engine, headless only (no display, no audio device).
- MCP server `godot` - structured engine tools. Prefer `run_project` + debug
  output over shell runs; prefer scene tools over hand-editing `.tscn`.
- `gdformat` / `gdlint` - format and lint GDScript.
- GDScript LSP - opencode starts `/usr/local/bin/godot-lsp` for `.gd` files.
  It boots a headless editor per project, so the first request can take ~30s
  (asset import). Do not kill and restart it repeatedly.

## Workflow

1. First time in a project (or after adding assets):
   `godot --headless --path . --import`
2. Validate a script: `godot --headless --path . --check-only --script res://<path>.gd`
3. Lint, then format: `gdlint <files>` and `gdformat <files>`
4. Run the project or a scene: prefer the MCP `run_project` tool (captures
   errors). Shell fallback: `godot --headless --path . res://<scene>.tscn --quit-after 300`
5. Tests: if `addons/gut/` exists:
   `godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`

## Gotchas

- Always pass `--path .` (or the project dir); the engine keeps no global
  project list in this container.
- `--check-only` catches parse/compile errors only; runtime behavior still
  needs a real run.
- Headless means no rendering - verify visuals via logic scripts and exit
  codes, not screenshots.
- Never hand-edit `.godot/` or `*.uid` files; regenerate with `--import`.
EOF

COPY inpaint /usr/local/bin/inpaint
RUN chmod +x /usr/local/bin/inpaint

COPY <<'EOF' /root/.config/opencode/skills/inpaint/SKILL.md
---
name: inpaint
description: Fill or remove a marked region of an image. Use for watermark/text/scratch removal, patching defects, or replacing an object with plausible background when the user asks to inpaint, clean up, or retouch an image using a mask.
---

## Tools in this container

`inpaint IMAGE MASK OUT [--radius 5] [--ai "PROMPT"]`

The mask is any image where white (or opaque alpha) marks the pixels to
replace; it is resized to the input's size. Local OpenCV fill is the default
(Telea, `--radius` in pixels). `--ai PROMPT` re-generates the frame through
OpenRouter instead and needs `OPENROUTER_API_KEY`; the prompt should describe
what belongs in the marked area. `INPAINT_MODEL` overrides the default
`google/gemini-3.1-flash-image`.

## Workflow

1. Look at the image first (read it) and decide the exact region to replace.
2. Make a mask with Pillow - a separate file, white on black:

   ```bash
   python3 - <<'PY'
   from PIL import Image, ImageDraw
   m = Image.new("L", (WIDTH, HEIGHT), 0)
   ImageDraw.Draw(m).rectangle([x0, y0, x1, y1], fill=255)
   m.save("mask.png")
   PY
   ```

3. Run `inpaint`, then read `OUT` to confirm the result before reporting it.

## Which mode

- Local: small, flat or textured defects (text, logos, scratches, dust). Fast,
  offline, leaves every pixel outside the mask untouched.
- `--ai`: large or structural holes where the fill must look like something
  (a removed person, a rebuilt wall). Slower, costs roughly $0.01-0.10 per
  image, and returns a re-generated frame - resolution may change and pixels
  outside the mask may drift slightly.

## Gotchas

- The mask must extend a few pixels past the defect; a mask tighter than the
  defect lets the defect bleed back in during the local fill.
- Local fill invents smooth color only - it cannot restore structure, and a
  large mask collapses into a smear. Use `--ai` for structure.
- A missing key or a 400 from OpenRouter is an environment problem: report it
  instead of silently falling back to the local fill.
EOF

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
