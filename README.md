# selfhost-compose

Docker Compose definitions for my self-hosted services, deployed via [Coolify](https://coolify.io) and managed GitOps-style with [Renovate](https://docs.renovatebot.com/).

## Layout

Each root-level `*.yaml` file is one independently deployable stack. Directory-based stacks keep their build context next to the compose file.

| File | Purpose |
|---|---|
| `aiostreams.yaml` | [AIOStreams](https://github.com/Viren070/AIOStreams) (Stremio addon) + NZBHydra2 |
| `jellyfin.yaml` | Media server stack: Jellyfin, *arr suite, download clients, Tdarr |
| `proxy.yaml` | Public reverse-proxy edge for selected internal services |
| `jellyswarm.yaml` | [Jellyswarrm](https://github.com/LLukas22/Jellyswarrm): combines the Jellyfin and AIOStreams media servers into one |
| `opencode.yaml` | [OpenCode](https://opencode.ai) server (built from `opencode/`) |

## How it's deployed

- **Coolify** deploys directly from this repository
- Each Coolify resource has a **watch path** matching its compose file, so a push only redeploys the stack that actually changed
- Publicly reachable services are exposed exclusively through the platform's proxy with automatic TLS (`SERVICE_FQDN_*` variables in the compose files request domains). Everything else stays internal
- Secrets are provided through coolify environment variables

## Conventions

- **Images are pinned** to specific version tags
- **No `container_name`** since Coolify auto generates those. If you want to deploy these configs outside of coolify, you should probably add those

## Renovate

`renovate.json` watches every root-level compose file plus the Dockerfile, pins digests, and groups update PRs per stack.
