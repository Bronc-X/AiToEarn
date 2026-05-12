# AiToEarn setup handoff log

Date: 2026-05-10
Workspace: D:\Code\Toni\AItoearn

## Goal

Prepare the GitHub AiToEarn project so the remaining work is only manual login, secrets, and elevated Windows setup.

## Current status

- Upstream repository cloned:
  - Upstream: https://github.com/yikart/AiToEarn.git
  - Local branch: `main`
  - Local commit when cloned: `1a76d530 Update README.md`
- Git remotes configured:
  - `origin`: `https://github.com/Bronc-X/AiToEarn.git`
  - `upstream`: `https://github.com/yikart/AiToEarn.git`
- Fork verified:
  - `git ls-remote origin HEAD` returns `1a76d530bb9cbe20088b09bd432a291c74781cb4`.
- Git user configured:
  - `Bronc-X <broncin@163.com>`
- GitHub CLI installed:
  - `gh version 2.92.0`
  - `gh auth status` still says no host is logged in.
  - GitHub CLI login is optional now unless you want `gh` features; plain Git can reach the fork.
- Portable Node 20 installed for Electron:
  - `.local-tools/node-v20`
  - `v20.20.2`
- `.local-tools/` is ignored in the root `.gitignore`.

## Dependencies installed

- `project/aitoearn-backend`: `pnpm install --frozen-lockfile`
- `project/aitoearn-web`: `pnpm install --frozen-lockfile`
- `project/aitoearn-electron/server`: `pnpm install --frozen-lockfile`
- `project/aitoearn-electron`: installed via `scripts/install-electron.ps1` using repo-local Node 20 and better-sqlite3 mirror settings.
- Verified Electron native dependency:
  - `npm ls better-sqlite3 --depth=0` shows `better-sqlite3@11.9.1`

## Config files prepared

- Backend local configs copied:
  - `project/aitoearn-backend/apps/aitoearn-ai/config/local.config.js`
  - `project/aitoearn-backend/apps/aitoearn-server/config/local.config.js`
- Frontend type entry restored:
  - `project/aitoearn-web/next-env.d.ts`
- Frontend `.gitignore` no longer ignores `next-env.d.ts`.
- Frontend `pnpm-workspace.yaml` added by `pnpm approve-builds --all` to allow `sharp` and `@parcel/watcher` build scripts.

## Verification completed

- Backend AI build:
  - `pnpm nx build aitoearn-ai`
  - Passed.
- Backend server build:
  - `pnpm nx build aitoearn-server`
  - Passed.
- Web type-check:
  - `pnpm run type-check`
  - Passed after restoring `next-env.d.ts`.
- Web production build:
  - `pnpm run build`
  - Compiled successfully, type checked, generated static pages, then failed at the final Next standalone trace copy step.
  - Root cause: current non-elevated Windows shell cannot create symlinks under `.next/standalone`.
  - This is a local permission issue, not a TypeScript or app compile error.

## Remaining blockers

- Docker Desktop / WSL:
  - Current shell is not elevated.
  - `winget install Docker.DockerDesktop` was attempted and failed because admin rights are required.
  - A later elevated attempt showed Docker Desktop refusing `C:\ProgramData\DockerDesktop` because the folder owner was not an elevated account.
  - WSL package `Microsoft.WSL 2.7.3.0` is installed, but WSL still reports missing Windows optional feature or virtualization readiness from this non-elevated shell.
  - `scripts/install-docker-admin.ps1` now repairs the Docker Desktop data folder owner, enables WSL and Virtual Machine Platform, then installs Docker Desktop.
  - Installer was downloaded under `C:\Users\Administrator\AppData\Local\Temp\WinGet\Docker.DockerDesktop.4.71.0\`.
- Web standalone build on Windows:
  - Requires administrator PowerShell or Windows Developer Mode so Next can create symlinks.
- Secrets:
  - Relay API key and social login/OAuth credentials must be entered manually.
  - Do not store passwords or personal social credentials in this repo.

## Scripts added

- `scripts/setup-github-fork.ps1`
  - Logs into GitHub if needed, creates/verifies `Bronc-X/AiToEarn`, and fixes remotes.
- `scripts/install-docker-admin.ps1`
  - Run only from elevated PowerShell. Installs Docker Desktop and WSL.
- `scripts/start-aitoearn-docker.ps1`
  - Runs `docker compose up -d` and prints `http://localhost:8080`.
- `scripts/start-aitoearn-auto.ps1`
  - Double-click helper logic: starts Docker Desktop if possible, runs Docker Compose, waits for the web service, and opens the browser.
- `START_AITOEARN.bat`
  - Root-level double-click entry point for `scripts/start-aitoearn-auto.ps1`.
- `scripts/install-electron.ps1`
  - Uses repo-local Node 20 and installs Electron app dependencies with mirror settings.
- `scripts/open-prelogin-tabs.ps1`
  - Opens GitHub, AiToEarn, and supported social platform login pages.
- `scripts/open-developer-credential-tabs.ps1`
  - Opens developer credential portals if Relay is not used.

## Tomorrow commands

Verify GitHub fork/remotes:

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\setup-github-fork.ps1
```

Docker route, from elevated PowerShell:

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\install-docker-admin.ps1
```

After reboot if needed:

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\start-aitoearn-docker.ps1
```

Open social and AiToEarn login tabs:

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\open-prelogin-tabs.ps1
```

## Manual login/secrets checklist

- GitHub:
  - Fork is already reachable as `Bronc-X/AiToEarn`.
  - Run `gh auth login` only if you want GitHub CLI features later.
- AiToEarn Relay:
  - Login/register at https://aitoearn.ai or https://aitoearn.cn.
  - Create an API key in Settings.
  - Put it in `docker-compose.yml` as `RELAY_API_KEY`.
- Social media accounts:
  - Login manually in browser.
  - After AiToEarn starts, bind/authorize accounts inside the app.
- Supported social targets:
  - Douyin, Xiaohongshu/Rednote, Kuaishou/Kwai, Bilibili, TikTok, YouTube, Facebook, Instagram, Threads, Twitter/X, Pinterest, LinkedIn.

## Notes

- Prefer Docker for first run because it starts MongoDB, Redis, RustFS, backend, AI service, web, and nginx together.
- Web build failing at symlink stage should be retried from elevated PowerShell or after enabling Windows Developer Mode.
- Do not commit `node_modules`, `.next`, `.local-tools`, local DB files, or personal secrets.
