#!/usr/bin/env bash
# Fresh-Fish smoke tests for the local pi completion.  Does not execute pi.
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
completion="$repo_dir/pi.fish"

fish -n "$completion"

complete() {
  fish -C "source '$completion'" -c "complete -C '$1'"
}

assert_contains() {
  local input=$1 expected=$2
  if ! complete "$input" | grep -q -- "^${expected}"; then
    printf 'Expected completion %q for %q\n' "$expected" "$input" >&2
    exit 1
  fi
}

assert_contains 'pi --' '--thinking'
assert_contains 'pi --thi' '--thinking'
assert_contains 'pi --thinking ' 'xhigh'
assert_contains 'pi --mode ' 'json'
assert_contains 'pi -t ' 'read'
assert_contains 'pi --provider ' 'openai-codex'
assert_contains 'pi --model ' 'openai-codex/'
assert_contains 'pi --session-dir /home/ggergely/' '/home/ggergely/bin/'
assert_contains 'pi auth ' 'check'
assert_contains 'pi auth check --' '--no-refresh'
assert_contains 'pi update --' '--extensions'

printf 'pi Fish completion tests passed\n'
