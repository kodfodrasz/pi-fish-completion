#!/usr/bin/env fish
# Isolated tests for pi.fish and its installer. Does not execute pi.
set -l repo_dir (cd (dirname (status filename)); and pwd)
set -gx PI_TEST_REPO_DIR $repo_dir
set -g temp_root (mktemp -d); or exit 1
function cleanup --on-event fish_exit
    rm -rf -- "$temp_root"
end
set -gx HOME "$temp_root/home with spaces"
set -gx XDG_CONFIG_HOME "$temp_root/config with spaces"
set -gx PI_CODING_AGENT_DIR "$temp_root/agent with spaces"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$PI_CODING_AGENT_DIR/sessions" "$PI_CODING_AGENT_DIR/themes"
command -v jq >/dev/null; or begin
    echo 'jq is required' >&2
    exit 1
end

function complete_pi --argument-names line
    env HOME="$HOME" XDG_CONFIG_HOME="$XDG_CONFIG_HOME" PI_CODING_AGENT_DIR="$PI_CODING_AGENT_DIR" fish --no-config -C 'source "$PI_TEST_REPO_DIR/pi.fish"' -c "complete -C '$line'"
end
function assert_contains --argument-names line expected
    set -l candidates (complete_pi "$line")
    or begin
        printf 'Completion failed for %s\n' (string escape -- "$line") >&2
        exit 1
    end
    string match -rq -- '^(?:'(string escape --style=regex -- "$expected")')(\t|$)' $candidates
    or begin
        printf 'Expected completion %s for %s\n' (string escape -- "$expected") (string escape -- "$line") >&2
        exit 1
    end
end
function assert_not_contains --argument-names line unexpected
    set -l candidates (complete_pi "$line")
    or begin
        printf 'Completion failed for %s\n' (string escape -- "$line") >&2
        exit 1
    end
    string match -rq -- '^(?:'(string escape --style=regex -- "$unexpected")')(\t|$)' $candidates
    and begin
        printf 'Unexpected completion %s for %s\n' (string escape -- "$unexpected") (string escape -- "$line") >&2
        exit 1
    end
end

fish -n "$repo_dir/pi.fish"; or exit 1
assert_contains 'pi --' --thinking
assert_contains 'pi --thi' --thinking
assert_contains 'pi --thinking ' xhigh
assert_contains 'pi --mode ' json
assert_contains 'pi -t ' read
assert_contains 'pi --tools read,' read,read
assert_contains 'pi --provider ' openai-codex
assert_contains 'pi --no-' --no-tools
assert_contains 'pi -' -nt
assert_contains 'pi auth ' check
assert_contains 'pi --system-prompt auth --' --thinking
assert_not_contains 'pi --system-prompt auth --' --credentials
assert_not_contains 'pi --system-prompt update --' --self
assert_not_contains 'pi -- --' --thinking
assert_contains 'pi auth check --' --no-refresh
assert_contains 'pi update --' --extensions
assert_contains 'pi mcp ' add
assert_contains 'pi mcp add server --' --url
assert_contains 'pi mcp login server --' --timeout
assert_not_contains 'pi mcp add server -- --' --help
assert_not_contains 'pi mcp add server -- --' --url
assert_contains 'pi -xt ' read
assert_contains 'pi --tools read,b' read,bash

printf '{"providers":{"cache-provider":{"models":[{"id":"cached-model"}]}}}\n' >"$PI_CODING_AGENT_DIR/models-store.json"
printf '{"defaultProvider":"settings-provider"}\n' >"$PI_CODING_AGENT_DIR/settings.json"
printf '{"theme":"dark"}\n' >"$PI_CODING_AGENT_DIR/themes/theme with spaces.json"
printf '{}\n' >"$PI_CODING_AGENT_DIR/sessions/session with spaces.jsonl"
assert_contains 'pi --provider ' cache-provider
assert_contains 'pi --model ' cache-provider/cached-model
assert_contains 'pi --provider ' settings-provider
assert_contains 'pi --model ' cache-provider/cached-model
assert_contains 'pi --use-theme ' 'theme with spaces'
assert_contains 'pi --session ' "$PI_CODING_AGENT_DIR/sessions/session with spaces.jsonl"
mkdir -p "$PI_CODING_AGENT_DIR/sessions/subagent-artifacts"
printf '{}\n' >"$PI_CODING_AGENT_DIR/sessions/subagent-artifacts/hidden.jsonl"
assert_not_contains 'pi --session ' "$PI_CODING_AGENT_DIR/sessions/subagent-artifacts/hidden.jsonl"
printf '{"flat-provider":{"models":[{"id":"flat-model","name":"Flat model"}]}}\n' >"$PI_CODING_AGENT_DIR/models-store.json"
assert_contains 'pi --model ' flat-provider/flat-model
assert_contains 'pi --models flat-provider/flat-model,' flat-provider/flat-model,flat-provider/flat-model

printf '{malformed json\n' >"$PI_CODING_AGENT_DIR/models-store.json"
assert_contains 'pi --provider ' openai
assert_not_contains 'pi --model ' flat-provider/flat-model
rm "$PI_CODING_AGENT_DIR/models-store.json"
assert_contains 'pi --provider ' openai
assert_not_contains 'pi --model ' flat-provider/flat-model

sh -n "$repo_dir/deploy.sh"; or exit 1
env HOME="$HOME" XDG_CONFIG_HOME="$XDG_CONFIG_HOME" sh "$repo_dir/deploy.sh"
test -f "$XDG_CONFIG_HOME/fish/completions/pi.fish"; or exit 1
cmp -s "$repo_dir/pi.fish" "$XDG_CONFIG_HOME/fish/completions/pi.fish"; or exit 1
echo 'pi Fish completion tests passed'
