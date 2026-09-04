#!/usr/bin/env bash
#
# Regenerate the "firmware" lists in every hw_result.json from what is
# actually on disk, and report any that were out of date.
#
# The lists do not maintain themselves: renaming an MCU folder or swapping
# a .hex leaves the JSON pointing at a path that no longer exists. Run this
# after changing any firmware, before committing.
#
#   ./tools/update_firmware_lists.sh          # rewrite the lists
#   ./tools/update_firmware_lists.sh --check   # report only, change nothing
#                                              # (exit 1 if anything is stale)
#
# The "hw_result" block is preserved untouched — only "firmware" is rebuilt.

set -euo pipefail

cd "$(dirname "$0")/.."

check_only=0
[ "${1:-}" = "--check" ] && check_only=1

emit_array() {
    # $1 = key name, $2 = newline-separated paths, $3 = trailing comma or empty
    local key="$1" items="$2" tail="$3"
    if [ -z "$items" ]; then
        printf '    "%s": []%s\n' "$key" "$tail"
        return
    fi
    printf '    "%s": [\n' "$key"
    printf '%s\n' "$items" | sed 's/.*/      "&",/' | sed '$ s/,$//'
    printf '    ]%s\n' "$tail"
}

stale=0

for json in $(find . -name hw_result.json -not -path './.git/*' | sort); do
    model_dir="$(dirname "$json")"

    application="$(cd "$model_dir" && find Application -name '*.hex' 2>/dev/null | sort || true)"
    testing="$(cd "$model_dir" && find Testing -name '*.hex' 2>/dev/null | sort || true)"

    listed="$(grep -oE '"(Application|Testing)/[^"]+"' "$json" | tr -d '"' | sort || true)"
    actual="$(printf '%s\n%s\n' "$application" "$testing" | grep -v '^$' | sort || true)"

    if [ "$listed" = "$actual" ]; then
        echo "ok      $model_dir"
        continue
    fi

    stale=1
    echo "STALE   $model_dir"
    diff <(echo "$listed") <(echo "$actual") \
        | sed 's/^</          json: /; s/^>/          disk: /' \
        | grep -Ev '^[0-9-]' || true

    [ "$check_only" -eq 1 ] && continue

    # Preserve the hw_result block verbatim; rebuild only the firmware block.
    awk '/"hw_result":/,0' "$json" > "$json.hwblock"
    {
        echo '{'
        echo '  "firmware": {'
        emit_array application "$application" ','
        emit_array testing     "$testing"     ''
        echo '  },'
        cat "$json.hwblock"
    } > "$json.new"
    mv "$json.new" "$json"
    rm -f "$json.hwblock"
    echo "        rewritten"
done

if [ "$check_only" -eq 1 ] && [ "$stale" -eq 1 ]; then
    echo
    echo "Firmware lists are out of date. Run ./tools/update_firmware_lists.sh"
    exit 1
fi

exit 0
