#!/usr/bin/bash
set -o nounset
set -o errtrace
function catch_error {
    local LEC=$? name i line file
    echo "Traceback (most recent call last):" >&2
    for ((i = ${#FUNCNAME[@]} - 1; i >= 0; --i)); do
        name="${FUNCNAME[$i]}"
        line="${BASH_LINENO[$i]}"
        file="${BASH_SOURCE[$i]}"
        echo "  File ${file@Q}, line ${line}, in ${name@Q}" >&2
    done
    echo "Error: [ExitCode: ${LEC}]" >&2
    exit "${LEC}"
}
trap catch_error ERR

temp=$(mktemp)
trap 'rm "$temp"' EXIT

find ./* -name '*.json' -print0 | while read -rd '' file; do
    jq . --tab < "${file}" | sed 's/\t/    /g' > "${temp}"
    cat "${temp}" > "${file}"
done

git status
