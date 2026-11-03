# Contributing

Sleep Tracker is a small, offline Android app. These rules keep it that way.

## Before you start

- Found a bug or have an idea for a feature? Open an issue.
- Keep it simple. Pick the simplest thing that handles the case, and leave out what nobody asked for.
- Do one thing per branch. Unrelated changes get their own branch.

## Branches

- Branch from `main`. Changes reach `main` through a pull request.
- Name branches `type/short-description`, in lowercase words joined by hyphens, using one of the types below.

| Type | Use for |
|---|---|
| `feat` | New or changed behaviour |
| `fix` | Bug fixes |
| `test` | Test changes only |
| `docs` | Documentation only |
| `chore` | Builds, dependencies and tooling |

## Commits

- Write the subject as `type: short imperative summary`, in lowercase with no full stop.
- Add a body when the reason isn't obvious from the subject. Explain why, not what.
- Each commit should build and pass the tests on its own.

## Code

- Match the code around your change: its naming, comment density and layout.

## Pull requests

Run these first. All must be clean:

```
dart format lib test
flutter analyze
flutter test
```

- Add or update tests for any change in behaviour.
- Add user-visible changes to `CHANGELOG.md` under `## [Unreleased]`, in plain language.
- Open pull requests against `main`.
- Explain what changed and why.
- Screenshots help for UI changes.

## License

By contributing, you agree that your work is licensed under the GPL-3.0, the same as the project.
