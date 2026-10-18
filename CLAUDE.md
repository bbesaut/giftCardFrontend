# CLAUDE.md - Gift Card Front-End

Flutter front-end (**web, desktop and mobile** from one codebase) for the Gift Card Service backend (Spring Boot, repo `bbesaut/giftCardMicroService`, local path `c:\Users\bapti\Downloads\p2p`). Built and operated the way a company would: pinned toolchain, layered architecture, CI gates, automated deploy.

## 🎯 Current Goal (Milestone 0 - "walking skeleton")
One page showing a static text, **deployed to production on Render through a real CI/CD pipeline**. No feature code, no API call yet.

The point is to prove the whole delivery chain end to end (commit -> CI -> build -> deploy -> live URL) before any business code exists. Every later feature then ships through a pipeline that is already trusted.

Done when:
- [x] Project scaffolded with a pinned Flutter version (FVM), all platforms enabled (web, android, ios, windows, macos, linux)
- [x] One screen displaying a text, covered by a widget test
- [ ] CI on every PR: format check, `analyze --fatal-infos`, tests with coverage, `build web`
- [ ] Production build served on Render over HTTPS, deployed automatically only after CI passes on `main`
- [ ] README documents setup, commands and the release flow

Out of scope for now: login, API client, state management wiring, routing, i18n.

## 📋 Stack
- Flutter (stable, pinned with FVM in `.fvmrc` **and** `pubspec.yaml` `environment.flutter`; update both together) + Dart. Platforms: web (deployed first, Milestone 0), Android, iOS, Windows, macOS, Linux. Bundle id / org: `com.finovago`
- Planned, added only when a feature needs it (ask before adding any dependency): `flutter_bloc` (Cubit), `get_it` (composition root), `dio`, `freezed` + `json_serializable`, `fpdart` (`Either<Failure, T>`), `go_router`, `bloc_test` + `mocktail`
- Same conventions as the author's `flutter_demo` project (`c:\Users\bapti\Downloads\flutter_demo`, see its `ARCHITECTURE.md`)
- Hosting: Render, same account as the backend
- CI: GitHub Actions

## ⚙️ Commands
```bash
fvm install                                   # Install the pinned Flutter version
fvm flutter pub get
fvm flutter run -d chrome                     # Dev
fvm dart format --set-exit-if-changed .       # Format check (CI)
fvm flutter analyze --fatal-infos             # Static analysis (CI)
fvm flutter test --coverage                   # Unit + widget tests (CI)
fvm flutter build web --release --dart-define=API_BASE_URL=<url>   # Production build
```

## 🏗️ Architecture (target)
Feature-first Clean Architecture, dependencies point inward: `presentation -> domain <- data`. The domain layer imports nothing from Flutter, Dio or any storage package.

```
lib/
├── core/        config (AppConfig via --dart-define), di, errors (sealed Failure), logging, network, theme
└── features/<feature>/{domain,data,presentation}
```

Rules:
- Constructor injection only; only `main()` resolves from the service locator.
- No exceptions across layers: repositories map them to `Failure` and return `Either<Failure, T>`.
- `build()` stays pure; split screens into small `const` widget classes, never `_buildX()` methods.
- No business logic in widgets; widgets render state, Cubits own it.
- Platform-specific code (cookies/CORS on web vs. secure storage on mobile/desktop) hides behind `domain` interfaces, never `if (kIsWeb)` in widgets.
- Configuration is build-time only (`--dart-define`), never hardcoded, **no secrets in the bundle** (any client app can be decompiled).

## 🔌 Backend Contract (what the front must respect)
- Base URL comes from `API_BASE_URL`. Endpoints live under `/api/v1/...`.
- **Auth**: access token (JWT, ~15 min) is returned in the JSON body and kept **in memory only**, never in `localStorage`. The refresh token is an `HttpOnly; Secure; SameSite=None` cookie on `/api/v1/auth` that JS cannot read: the HTTP client must send credentials on cross-origin calls (Dio web adapter: `withCredentials = true`).
- **CORS**: the backend allows an exact origin allowlist (`CORS_ALLOWED_ORIGINS`, no wildcard, HTTPS required in prod). The deployed front origin must be added there, not in code. Dev default is `https://localhost:4200`, so run the dev server on that origin: `flutter run -d chrome --web-port 4200 --web-tls-cert-path <crt> --web-tls-cert-key-path <key>` with a mkcert certificate (see the backend's "Dev HTTPS").
- Headers readable from JS: `X-Correlation-Id`, `X-Response-Time`, `Retry-After`. Surface the correlation id in error reports.
- `X-Api-Key` is backend-to-backend only: the front never uses or stores one.
- Errors share one shape `{ "error": "...", "message": "..." }`; map 401 -> refresh once then logout, 403 `Email Not Verified` -> "check your inbox" screen, 429 -> honor `Retry-After`.

## 🚀 CI/CD
- `.github/workflows/ci.yml`: on every PR and push to `develop`/`main` -> checkout, setup Flutter from the pinned version, `pub get` (cached), format, analyze, test + coverage, `build web`. Build artifact uploaded.
- Only the web build is deployed in Milestone 0. Mobile/desktop pipelines (signing, stores) come later; iOS/macOS builds need a macOS runner.
- Deploy: Render, production built with the real `API_BASE_URL`. Auto-deploy gated on CI (Render "After CI Checks Pass") for `main` only. Hosting shape (Docker + nginx web service vs static site fed by CI) is decided when we build the pipeline; either way the SPA needs a fallback to `index.html` and security headers.
- Branch protection on `main`/`develop`: PR required, CI green required.

## 📌 Conventions
- All code, comments and docs in English.
- Unit/widget tests required for public behavior; tests mirror `lib/` structure.
- Never hardcode secrets; never commit `.env` or certificates (`certs/` gitignored).
- Ask before adding a dependency.
- Prefer clear code over clever code; senior-level, production-ready quality.
- Generated files (`*.g.dart`, `*.freezed.dart`) are not committed.

## 📝 Git
- Gitflow: `main` (prod), `develop`, `feature/*`, `fix/*`. Never force push to `main`. Never push to `main` without CI green.
- Atomic commits, one concern each (tooling vs. feature vs. CI vs. docs). Messages written like a human: short, terse dashes, no filler.
- Conventional prefixes: `feat:`, `fix:`, `ci:`, `docs:`, `test:`, `chore:`.

## ⛔ DO NOT
- Store tokens in `localStorage`/`sessionStorage` (web) or plain `SharedPreferences` (mobile/desktop: use secure storage)
- Commit secrets, certificates or `.env`
- Put a wildcard or http origin into the backend CORS config to "make it work"
- Deploy from a laptop: production only ships through the pipeline
