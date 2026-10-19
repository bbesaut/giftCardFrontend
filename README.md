# Gift Card Front-End

Flutter front-end (web, desktop and mobile from one codebase) for the Gift Card Service backend ([giftCardMicroService](https://github.com/bbesaut/giftCardMicroService)).

Project conventions and architecture rules live in [CLAUDE.md](CLAUDE.md).

## Prerequisites

- [FVM](https://fvm.app) (Flutter Version Management). The Flutter version is pinned in `.fvmrc` and `pubspec.yaml` (`environment.flutter`); update both together.
- Chrome, to run the web target locally.

## Setup

```bash
fvm install          # Install the pinned Flutter version
fvm flutter pub get  # Fetch dependencies
```

## Configuration

Settings are compile-time values (Flutter apps cannot read a `.env` at runtime), loaded from a JSON file with `--dart-define-from-file`. They end up in the bundle, so they are **public**: never put a secret in them.

| File | Purpose | Committed |
|---|---|---|
| `config/dev.json` | Shared dev settings (backend on `https://localhost:8080`) | yes |
| `config/local.json` | Your personal overrides | no (gitignored) |

| Key | Meaning | Default |
|---|---|---|
| `API_BASE_URL` | Backend base URL, no trailing slash | `https://localhost:8080` |

Code reads them through `AppConfig` (`lib/core/config/app_config.dart`), never with `String.fromEnvironment` directly. In production the value comes from the Render service environment (passed to the Docker build as `API_BASE_URL`).

## Run

```bash
fvm flutter run -d chrome --dart-define-from-file=config/dev.json
```

In VS Code, the launch configuration `gift_card_front (dev, chrome)` does the same.

## Quality gate

Run these commands **in this order** before opening a pull request. They are exactly the steps of the CI job `Quality gate` (`.github/workflows/ci.yml`), cheapest first, so a failure shows up as early as possible.

```bash
fvm flutter pub get                                    # 1. Install dependencies
fvm dart format --output=none --set-exit-if-changed .  # 2. Formatting check (does not modify files)
fvm flutter analyze --fatal-infos                      # 3. Static analysis (infos fail the build too)
fvm flutter test --coverage                            # 4. Tests, writes coverage/lcov.info
fvm flutter build web --release                        # 5. Production build must compile
```

To fix formatting instead of only checking it: `fvm dart format .`

The CI also runs a second job, `Docker image` (requires Docker), in parallel with the quality gate:

```bash
docker build --build-arg API_BASE_URL=https://api.example.invalid -t gift-card-front:local .  # 6. Production image builds
docker run --rm -e PORT=8080 -p 8080:8080 gift-card-front:local                                # 7. Serve it, then open http://localhost:8080 (health: /healthz)
```

A third CI job, `Desktop build`, compiles the app on each desktop OS (one runner per OS, because Flutter cannot cross-compile desktop targets). Locally, only your own OS can be built:

```bash
fvm flutter build windows --release  # 8. On Windows (needs Visual Studio with "Desktop development with C++")
fvm flutter build macos --release    #    On macOS (needs Xcode)
fvm flutter build linux --release    #    On Linux (needs clang, cmake, ninja, pkg-config, libgtk-3-dev)
```

On Windows, the same job then builds the installer with [Inno Setup](https://jrsoftware.org/isinfo.php) and smoke tests it (silent install, checks, silent uninstall). Install Inno Setup once (`winget install --id JRSoftware.InnoSetup -e`), then:

```powershell
./installer/windows/build-installer.ps1 -Version 0.0.0-local  # 9. Writes gift-card-front-0.0.0-local-windows-x64-setup.exe at the repo root
./installer/windows/test-installer.ps1 -Version 0.0.0-local   # 10. Installs for the current user in a temp folder, checks, uninstalls
```

The installer script is `installer/windows/setup.iss`. Its `AppId` identifies the app to Windows across versions: never change it.

Whenever a new kind of check is added to the CI (golden tests, integration tests, coverage threshold...), it is added to this list in the same pull request, in the same position.

## CI/CD

- **CI**: GitHub Actions, `.github/workflows/ci.yml`. Runs on every pull request and every push to `develop` and `main`.
- **CD (web)**: Docker image served by nginx, built and deployed by Render on every merge to `main`, once CI passes.
- **Release (desktop)**: `.github/workflows/release.yml` builds Windows, macOS and Linux packages when a `vX.Y.Z` tag is pushed and attaches them, with a `SHA256SUMS.txt` checksum file, to a GitHub Release. Windows ships an installer (`-setup.exe`); macOS and Linux are still plain archives. Nothing is signed yet.

## Releasing

Versions are automated with [release-please](https://github.com/googleapis/release-please), driven by [Conventional Commits](https://www.conventionalcommits.org) (`feat:` bumps the minor, `fix:` the patch, `feat!:` or a `BREAKING CHANGE:` footer the major; `ci:`, `docs:`, `chore:` do not release).

1. Merge `develop` into `main` through a pull request, as usual.
2. The `Release Please` workflow opens (or updates) a pull request on `main` named `chore(main): release X.Y.Z`. It contains the `pubspec.yaml` version bump and the `CHANGELOG.md` entry.
3. Review it, wait for CI, and merge it with a merge commit. This creates the `vX.Y.Z` tag and the GitHub Release.
4. The tag triggers the `Release` workflow, which builds the desktop packages and attaches them to that release.
5. Merge `main` back into `develop` through a pull request, so `develop` gets the version bump and the changelog.

Never edit `version:` in `pubspec.yaml` by hand: the `# x-release-please-version` marker on that line is how the tool finds it. The workflow needs a repository secret `RELEASE_PLEASE_TOKEN` (a personal access token with contents and pull requests write access): pull requests and tags created with the default token do not trigger other workflows.

## Git workflow

Gitflow: `main` (production), `develop`, `feature/*`. Both long-lived branches are protected by a ruleset: pull request required, CI must be green, no force push. Merge with a merge commit to keep the atomic commit history.
