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

## Run

```bash
fvm flutter run -d chrome
```

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

Whenever a new kind of check is added to the CI (golden tests, integration tests, coverage threshold...), it is added to this list in the same pull request, in the same position.

## CI/CD

- **CI**: GitHub Actions, `.github/workflows/ci.yml`. Runs on every pull request and every push to `develop` and `main`.
- **CD**: Docker image served by nginx, deployed on Render after CI passes on `main` (in progress).

## Git workflow

Gitflow: `main` (production), `develop`, `feature/*`. Both long-lived branches are protected by a ruleset: pull request required, CI must be green, no force push. Merge with a merge commit to keep the atomic commit history.
