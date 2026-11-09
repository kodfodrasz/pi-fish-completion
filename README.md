> ⚠️ **AI-generated code:** This project's code was generated using AI. Review and test it before use.

# Pi Fish completions

Fish shell completions for [Pi Coding Agent](https://github.com/earendil-works/pi), distributed as `@earendil-works/pi-coding-agent`.

Used daily for simple use cases, but **not exhaustively tested**. Bug reports and pull requests are welcome.

## Requirements and compatibility

- Linux or macOS.
- Fish and `jq` installed and available on `PATH`.
- Pi Coding Agent; the completion definitions target the current CLI.
- A POSIX shell and standard system utilities for installation. GNU utilities and Make are not required.

The CLI definitions were checked against **Pi 1.5.0**. Local tests passed on Linux with **Fish 4.6.0** and **jq 1.8.1**. Other versions are not guaranteed. GitHub Actions runs the isolated suite on Ubuntu and macOS and records the tested Fish and jq versions in each run; these tests do not execute Pi.

On macOS, Fish and jq can be installed with Homebrew:

```sh
brew install fish jq
```

## Install

```sh
git clone https://github.com/kodfodrasz/pi-fish-completion.git
cd pi-fish-completion
sh ./deploy.sh
```

The installer copies `pi.fish` to `${XDG_CONFIG_HOME:-$HOME/.config}/fish/completions/pi.fish`, replacing any existing file there. No administrator privileges are needed. For a custom Fish configuration directory, set `XDG_CONFIG_HOME` when running the installer.

Start a new Fish shell, or load the installed file in an existing one:

```fish
source "$__fish_config_dir/completions/pi.fish"
```

Try `pi --thi<Tab>`, `pi --provider <Tab>`, or `pi auth <Tab>`.

To update, pull this repository and run `sh ./deploy.sh` again. To uninstall, run this in Fish, then start a new shell:

```fish
rm -- "$__fish_config_dir/completions/pi.fish"
```

## Completion behavior

- Main CLI options, package commands, auth commands, and MCP configuration commands.
- Provider and model suggestions from local `models-store.json`, `models.json`, and `settings.json` files, plus built-in provider names.
- Comma-separated model and tool lists, session files, and theme names.

Local data is read from `$PI_CODING_AGENT_DIR`, or `~/.pi/agent` when unset. Session suggestions come from its `sessions` directory, excluding subagent artifacts. Theme suggestions include built-in names, its `themes` directory, and `.pi/themes` in the current directory.

Completion never starts Pi, invokes extensions, makes network requests, or sends LLM requests. It does not read authentication files. Model suggestions require an existing local model cache or custom model configuration; completion does not refresh catalogs. Dynamic extension-defined CLI options and configured MCP server names are not discovered.

## Development

Run from the repository root:

```sh
fish -n pi.fish test.fish
fish_indent --check pi.fish test.fish
sh -n deploy.sh
fish --no-config ./test.fish
```

The tests use temporary home, configuration, and agent directories with local JSON fixtures. They do not require an installed Pi or access to personal Pi data.

When updating for a Pi release, compare its CLI argument parser, auth command, package-management commands, and MCP CLI with `pi.fish`. Update the regression tests, run the suite on Linux and macOS, and record the checked Pi version here and in the completion header.

## License

[MIT](LICENSE).
