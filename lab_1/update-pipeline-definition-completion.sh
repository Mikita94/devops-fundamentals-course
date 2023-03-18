#!/usr/bin/env bash

_pipeline_completions() {
    options="--help --wizard --branch --owner --repo --poll-for-source-changes --configuration"
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "${options}" -- ${cur}))
    return 0
}

complete -o nospace -F _pipeline_completions update-pipeline-definition.sh