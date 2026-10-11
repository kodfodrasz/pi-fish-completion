# Fish completions for pi 0.85.1, generated 2026-09-23.
# CLI options were inspected in the installed parser:
# /usr/local/lib/node_modules/@earendil-works/pi-coding-agent/dist/cli/args.js
# plus auth-command.js and package-manager-cli.js.

function __pi_agent_dir
    if set -q PI_CODING_AGENT_DIR
        printf '%s\n' "$PI_CODING_AGENT_DIR"
    else
        printf '%s\n' "$HOME/.pi/agent"
    end
end

function __pi_providers
    # Built-ins from pi-ai's installed providers/all.js.  Add local custom,
    # cached-catalog, and configured-default provider IDs without running pi.
    printf '%s\n' amazon-bedrock ant-ling anthropic azure-openai-responses baseten cerebras cloudflare-ai-gateway cloudflare-workers-ai deepseek fireworks github-copilot google google-vertex groq huggingface kimi-coding minimax minimax-cn mistral moonshotai moonshotai-cn nvidia openai openai-codex opencode opencode-go openrouter qwen-token-plan qwen-token-plan-cn qwen-token-plan-individual radius together vercel-ai-gateway xai xiaomi xiaomi-token-plan-ams xiaomi-token-plan-cn xiaomi-token-plan-sgp zai zai-coding-cn
    set -l agent_dir (__pi_agent_dir)
    for file in "$agent_dir/models-store.json" "$agent_dir/models.json"
        test -r "$file"; and command jq -r 'if type == "object" then ((.providers // {}) | keys[]) else empty end' "$file" 2>/dev/null
    end
    test -r "$agent_dir/models-store.json"; and command jq -r 'keys[]' "$agent_dir/models-store.json" 2>/dev/null
    test -r "$agent_dir/settings.json"; and command jq -r '.defaultProvider // empty' "$agent_dir/settings.json" 2>/dev/null
end

function __pi_model_candidates
    # Cached remote catalogs and custom models are local JSON; this never starts pi,
    # accesses the network, invokes an extension, or sends an LLM request.
    set -l token (commandline -ct)
    set -l prefix (string replace -r '[^,]*$' '' -- "$token")
    set -l agent_dir (__pi_agent_dir)
    for file in "$agent_dir/models-store.json" "$agent_dir/models.json"
        test -r "$file"; or continue
        command jq -r '
            if has("providers") then
              .providers | to_entries[]? | .key as $provider |
              .value.models[]? | "\($provider)/\(.id)\t\(.name // .id)"
            else
              to_entries[]? | .key as $provider |
              .value.models[]? | "\($provider)/\(.id)\t\(.name // .id)"
            end
        ' "$file" 2>/dev/null | while read -l candidate
            printf '%s%s\n' "$prefix" "$candidate"
        end
    end
end

function __pi_session_files
    set -l session_dir (__pi_agent_dir)/sessions
    test -d "$session_dir"; or return
    # Do not offer pi-subagents transcripts as normal pi sessions.
    command find "$session_dir" -type f -name '*.jsonl' ! -path '*/subagent-artifacts/*' -printf '%p\tPi session\n' 2>/dev/null
end

function __pi_thinking_levels
    printf 'off\tDisable thinking\nminimal\tMinimal thinking\nlow\tLow thinking\nmedium\tMedium thinking\nhigh\tHigh thinking\nxhigh\tExtra-high thinking\nmax\tMaximum thinking\n'
end

function __pi_output_modes
    printf 'text\tPlain text output\njson\tJSON output\nrpc\tRPC output\n'
end

function __pi_tools
    printf 'read\tRead files\nbash\tRun shell commands\npowershell\tRun PowerShell commands\nedit\tEdit files\nwrite\tWrite files\ngrep\tSearch files\nfind\tFind files\nls\tList directories\n'
end

function __pi_comma_tools
    set -l prefix (string replace -r '[^,]*$' '' -- (commandline -ct))
    __pi_tools | while read -l candidate
        printf '%s%s\n' "$prefix" "$candidate"
    end
end

function __pi_tui_modes
    printf 'regular\tRegular TUI\nfullscreen\tFullscreen TUI\n'
end

function __pi_theme_names
    printf 'dark\tBuilt-in dark theme\nlight\tBuilt-in light theme\n'
    set -l agent_dir (__pi_agent_dir)
    for dir in "$agent_dir/themes" .pi/themes
        test -d "$dir"; or continue
        command find "$dir" -maxdepth 1 -type f -name '*.json' -printf '%f\n' 2>/dev/null | string replace -r '\.json$' ''
    end
end

function __pi_main_command
    not __fish_seen_subcommand_from install remove uninstall update list config auth
end

# Top-level commands
complete -c pi -n '__fish_use_subcommand' -f -a install -d 'Install an extension package'
complete -c pi -n '__fish_use_subcommand' -f -a remove -d 'Remove an extension package'
complete -c pi -n '__fish_use_subcommand' -f -a uninstall -d 'Alias for remove'
complete -c pi -n '__fish_use_subcommand' -f -a update -d 'Update pi, packages, or model catalogs'
complete -c pi -n '__fish_use_subcommand' -f -a list -d 'List installed extension packages'
complete -c pi -n '__fish_use_subcommand' -f -a config -d 'Configure package resources'
complete -c pi -n '__fish_use_subcommand' -f -a auth -d 'Print credentials or check provider readiness'

# Main CLI flags
complete -c pi -n '__pi_main_command' -l provider -r -f -a '(__pi_providers)' -d 'Provider name'
complete -c pi -n '__pi_main_command' -l model -r -f -a '(__pi_model_candidates)' -d 'Model ID or pattern'
complete -c pi -n '__pi_main_command' -l api-key -r -f -d 'API key'
complete -c pi -n '__pi_main_command' -l system-prompt -r -f -d 'System prompt text'
complete -c pi -n '__pi_main_command' -l append-system-prompt -r -d 'Append text or a file to the system prompt'
complete -c pi -n '__pi_main_command' -l mode -r -f -a '(__pi_output_modes)' -d 'Output mode'
complete -c pi -n '__pi_main_command' -l print -s p -f -d 'Process prompt non-interactively and exit'
complete -c pi -n '__pi_main_command' -l continue -s c -f -d 'Continue the previous session'
complete -c pi -n '__pi_main_command' -l resume -s r -f -d 'Select a session to resume'
complete -c pi -n '__pi_main_command' -l session -r -a '(__pi_session_files)' -d 'Session file or partial UUID'
complete -c pi -n '__pi_main_command' -l session-id -r -f -d 'Exact project session ID'
complete -c pi -n '__pi_main_command' -l fork -r -a '(__pi_session_files)' -d 'Session file or partial UUID to fork'
complete -c pi -n '__pi_main_command' -l session-dir -r -f -a '(__fish_complete_directories)' -d 'Session storage directory'
complete -c pi -n '__pi_main_command' -l no-session -f -d 'Do not save a session'
complete -c pi -n '__pi_main_command' -l name -s n -r -f -d 'Session display name'
complete -c pi -n '__pi_main_command' -l models -r -f -a '(__pi_model_candidates)' -d 'Comma-separated model patterns for cycling'
complete -c pi -n '__pi_main_command' -l no-tools -s nt -f -d 'Disable all tools'
complete -c pi -n '__pi_main_command' -l no-builtin-tools -s nbt -f -d 'Disable built-in tools only'
complete -c pi -n '__pi_main_command' -l tools -s t -r -f -a '(__pi_comma_tools)' -d 'Comma-separated tool allowlist'
complete -c pi -n '__pi_main_command' -l exclude-tools -s xt -r -f -a '(__pi_comma_tools)' -d 'Comma-separated tool denylist'
complete -c pi -n '__pi_main_command' -l thinking -r -f -a '(__pi_thinking_levels)' -d 'Thinking level'
complete -c pi -n '__pi_main_command' -l extension -s e -r -d 'Extension file (repeatable)'
complete -c pi -n '__pi_main_command' -l no-extensions -s ne -f -d 'Disable extension discovery'
complete -c pi -n '__pi_main_command' -l skill -r -d 'Skill file or directory (repeatable)'
complete -c pi -n '__pi_main_command' -l no-skills -s ns -f -d 'Disable skill discovery and loading'
complete -c pi -n '__pi_main_command' -l prompt-template -r -d 'Prompt template file or directory (repeatable)'
complete -c pi -n '__pi_main_command' -l no-prompt-templates -s np -f -d 'Disable prompt template discovery and loading'
complete -c pi -n '__pi_main_command' -l theme -r -d 'Theme file or directory (repeatable)'
complete -c pi -n '__pi_main_command' -l use-theme -r -f -a '(__pi_theme_names)' -d 'Initial interactive theme'
complete -c pi -n '__pi_main_command' -l no-themes -f -d 'Disable theme discovery and loading'
complete -c pi -n '__pi_main_command' -l no-context-files -s nc -f -d 'Disable AGENTS.md and CLAUDE.md discovery'
complete -c pi -n '__pi_main_command' -l export -r -d 'Export session file to HTML'
complete -c pi -n '__pi_main_command' -l list-models -f -d 'List models; optionally supply a search pattern'
complete -c pi -n '__pi_main_command' -l verbose -f -d 'Force verbose startup'
complete -c pi -n '__pi_main_command' -l tui-mode -r -f -a '(__pi_tui_modes)' -d 'TUI mode'
complete -c pi -n '__pi_main_command' -l approve -s a -f -d 'Trust project-local files for this run'
complete -c pi -n '__pi_main_command' -l no-approve -s na -f -d 'Ignore project-local files for this run'
complete -c pi -n '__pi_main_command' -l offline -f -d 'Disable startup network operations'
complete -c pi -n '__pi_main_command' -l help -s h -f -d 'Show help'
complete -c pi -n '__pi_main_command' -l version -s v -f -d 'Show version'

# Package-management subcommands
complete -c pi -n '__fish_seen_subcommand_from install remove uninstall config' -l local -s l -f -d 'Use project-local settings'
complete -c pi -n '__fish_seen_subcommand_from install remove uninstall list config update' -l approve -s a -f -d 'Trust project-local files'
complete -c pi -n '__fish_seen_subcommand_from install remove uninstall list config update' -l no-approve -s na -f -d 'Ignore project-local files'
complete -c pi -n '__fish_seen_subcommand_from install remove uninstall update list config' -l help -s h -f -d 'Show command help'
complete -c pi -n '__fish_seen_subcommand_from update' -l self -f -d 'Update pi only'
complete -c pi -n '__fish_seen_subcommand_from update' -l extensions -f -d 'Update installed packages only'
complete -c pi -n '__fish_seen_subcommand_from update' -l models -f -d 'Refresh model catalogs only'
complete -c pi -n '__fish_seen_subcommand_from update' -l all -f -d 'Update pi and all packages'
complete -c pi -n '__fish_seen_subcommand_from update' -l extension -r -d 'Update one package source'
complete -c pi -n '__fish_seen_subcommand_from update' -l force -f -d 'Reinstall pi if already current'

# auth and its nested commands
complete -c pi -n '__fish_seen_subcommand_from auth; and not __fish_seen_subcommand_from print-api-key print-bearer-token check' -f -a print-api-key -d 'Print an API key'
complete -c pi -n '__fish_seen_subcommand_from auth; and not __fish_seen_subcommand_from print-api-key print-bearer-token check' -f -a print-bearer-token -d 'Print an OAuth bearer token'
complete -c pi -n '__fish_seen_subcommand_from auth; and not __fish_seen_subcommand_from print-api-key print-bearer-token check' -f -a check -d 'Check provider readiness'
complete -c pi -n '__fish_seen_subcommand_from auth' -l provider -r -f -a '(__pi_providers)' -d 'Provider name'
complete -c pi -n '__fish_seen_subcommand_from auth' -l model -r -f -a '(__pi_model_candidates)' -d 'Model ID or pattern'
complete -c pi -n '__fish_seen_subcommand_from auth; and __fish_seen_subcommand_from print-bearer-token' -l min-expiry -r -f -d 'Minimum token validity (for example, 30m)'
complete -c pi -n '__fish_seen_subcommand_from auth; and __fish_seen_subcommand_from check' -l json -f -d 'Emit JSON'
complete -c pi -n '__fish_seen_subcommand_from auth; and __fish_seen_subcommand_from check' -l credentials -f -d 'Include credentials in output'
complete -c pi -n '__fish_seen_subcommand_from auth; and __fish_seen_subcommand_from check' -l no-refresh -f -d 'Do not refresh expired OAuth credentials'
complete -c pi -n '__fish_seen_subcommand_from auth' -l help -s h -f -d 'Show command help'
