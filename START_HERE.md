# AiToEarn local start checklist

This workspace is prepared for your personal fork target: `Bronc-X/AiToEarn`.

## 1. GitHub fork

The fork is already reachable. Run this any time you want to re-check or repair remotes:

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\setup-github-fork.ps1
```

The script will:

- Use the existing fork if it is reachable.
- Start `gh auth login` only if the fork cannot be reached and GitHub CLI is needed to create it.
- Keep these remotes:
  - `origin`: `https://github.com/Bronc-X/AiToEarn.git`
  - `upstream`: `https://github.com/yikart/AiToEarn.git`

## 2. Fastest app path: Docker

Docker Desktop needs elevated PowerShell on this machine.

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\install-docker-admin.ps1
```

Reboot if Windows asks. Then:

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\start-aitoearn-docker.ps1
```

Open:

```text
http://localhost:8080
```

## 3. Relay/API key

Relay is recommended because it avoids applying for every platform developer credential on day one.

1. Open `https://aitoearn.ai` or `https://aitoearn.cn`.
2. Register/login.
3. Go to Settings and create an API key.
4. Put the key into `docker-compose.yml`:

```yaml
RELAY_API_KEY: "your-api-key"
```

Local Relay callback:

```text
http://127.0.0.1:8080/api/plat/relay-callback
```

## 4. Social account pre-login

Open normal login tabs:

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\open-prelogin-tabs.ps1
```

Prepared login targets:

- GitHub
- AiToEarn
- Douyin
- Xiaohongshu / Rednote
- Kuaishou / Kwai
- Bilibili
- TikTok
- YouTube
- Facebook
- Instagram
- Threads
- Twitter / X
- Pinterest
- LinkedIn

If you decide not to use Relay, open developer credential portals:

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\open-developer-credential-tabs.ps1
```

OAuth callback format from the project docs:

```text
https://{APP_DOMAIN}/api/plat/{platform}/auth/back
```

## 5. Source development notes

Dependencies are installed for:

- `project/aitoearn-backend`
- `project/aitoearn-web`
- `project/aitoearn-electron/server`
- `project/aitoearn-electron`

Backend verification already passed:

```powershell
cd D:\Code\Toni\AItoearn\project\aitoearn-backend
pnpm nx build aitoearn-ai
pnpm nx build aitoearn-server
```

Web type-check already passed:

```powershell
cd D:\Code\Toni\AItoearn\project\aitoearn-web
pnpm run type-check
```

Web production build compiles, type-checks, and generates pages, then fails in this non-elevated shell at the final Next standalone symlink step. Retry from elevated PowerShell or after enabling Windows Developer Mode:

```powershell
cd D:\Code\Toni\AItoearn\project\aitoearn-web
pnpm run build
```

Electron dependency install uses the repo-local Node 20:

```powershell
cd D:\Code\Toni\AItoearn
powershell -ExecutionPolicy Bypass -File .\scripts\install-electron.ps1
```

Backend local config files already exist:

- `project/aitoearn-backend/apps/aitoearn-ai/config/local.config.js`
- `project/aitoearn-backend/apps/aitoearn-server/config/local.config.js`

These copied configs still expect MongoDB and Redis. Docker is the smoother first run because it starts MongoDB, Redis, RustFS, backend, AI service, web, and nginx together.
