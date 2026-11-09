#!/usr/bin/env fish
# Isolated tests for pi.fish and its installer. Does not execute pi.
set -l repo_dir (cd (dirname (status filename)); and pwd)
set -gx PI_TEST_REPO_DIR $repo_dir
set -l temp_root (mktemp -d)
set -l old_home $HOME
set -l old_xdg $XDG_CONFIG_HOME
set -l old_agent $PI_CODING_AGENT_DIR
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
    env HOME="$HOME" XDG_CONFIG_HOME="$XDG_CONFIG_HOME" PI_CODING_AGENT_DIR="$PI_CODING_AGENT_DIR" fish -C 'source "$PI_TEST_REPO_DIR/pi.fish"' -c "complete -C '$line'"
end
function assert_contains --argument-names line expected
    complete_pi "$line" | string match -rq -- "^$expected"
    or begin
        printf 'Expected completion %s for %s\n' (string escape -- "$expected") (string escape -- "$line") >&2
        exit 1
    end
end
function assert_not_contains --argument-names line unexpected
    complete_pi "$line" | string match -rq -- "^$unexpected"
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
assert_contains 'pi --tools read,' read,
assert_contains 'pi --provider ' openai-codex
assert_contains 'pi --no-' --no-tools
assert_contains 'pi -' -nt
assert_contains 'pi auth ' check
assert_not_contains 'pi --provider auth ' 'auth[[:space:]]'

printf '{"providers":{"cache-provider":{"models":[{"id":"cached-model"}]}}}\n' >"$PI_CODING_AGENT_DIR/models-store.json"
printf '{"defaultProvider":"settings-provider"}\n' >"$PI_CODING_AGENT_DIR/settings.json"
printf '{"theme":"dark"}\n' >"$PI_CODING_AGENT_DIR/themes/theme with spaces.json"
printf '{}\n' >"$PI_CODING_AGENT_DIR/sessions/session with spaces.jsonl"
assert_contains 'pi --provider ' cache-provider
assert_contains 'pi --model ' cache-provider/cached-model
assert_contains 'pi --provider ' settings-provider
assert_contains 'pi --model ' cache-provider/cached-model
assert_contains 'pi --use-theme ' 'theme with spaces'
assert_contains 'pi --session ' 'session with spaces'

printf '{malformed json\n' >"$PI_CODING_AGENT_DIR/models-store.json"
complete_pi 'pi --provider ' >/dev/null
complete_pi 'pi --model ' >/dev/null
rm "$PI_CODING_AGENT_DIR/models-store.json"
complete_pi 'pi --provider ' >/dev/null

sh -n "$repo_dir/deploy.sh"; or exit 1
env HOME="$HOME" XDG_CONFIG_HOME="$XDG_CONFIG_HOME" sh "$repo_dir/deploy.sh"
test -f "$XDG_CONFIG_HOME/fish/completions/pi.fish"; or exit 1
cmp -s "$repo_dir/pi.fish" "$XDG_CONFIG_HOME/fish/completions/pi.fish"; or exit 1
echo 'pi Fish completion tests passed'
