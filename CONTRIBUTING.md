# Contributing

Thanks for contributing to OpenClaw Launcher. This project is intentionally small and focused on a reliable one-click install.

## What to contribute

- Installer reliability improvements
- Clearer documentation
- Better error handling and edge cases
- Cross-platform fixes

## Development setup

No build system is required. Just edit the scripts and docs.

## Guidelines

- Keep the installer flow simple and predictable.
- Avoid interactive prompts unless they are necessary.
- Prefer clear, actionable error messages.
- Keep dependencies to zero (no extra install requirements).
- Use ASCII for new files unless the content is explicitly localized.

## Testing

Please test on at least one platform before opening a PR:

- Linux or macOS: `install.sh`
- Windows: `install.ps1`

If you cannot test, mention that in your PR description.
