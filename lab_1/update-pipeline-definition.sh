#!/usr/bin/env bash

# Getting pipeline path (2)
INPUT_PATH=$1
if [[ "$INPUT_PATH" =~ .json$ ]]
then
  shift
fi
OUTPUT_PATH="./pipeline-$(date +"%y-%m-%d-%T").json"

# Help (7)
help() {
    echo -e "$0 <file path> <options>\n"
    echo -e "Usage:\n"
    echo -e "$0 -h or --help                      display instructions on how to use this script"
    echo -e "$0 -w or --wizard                    enter the script parameters step by step"
    echo -e "$0 -b or --branch                    update GitHub branch name (Default: 'main')"
    echo -e "$0 -o or --owner                     update GitHub owner"
    echo -e "$0 -r or --repo                      update GitHub repository name"
    echo -e "$0 -p or --poll-for-source-changes   update PollForSourceChanges configuration (Default: false)"
    echo -e "$0 -c or --configuration             update BUILD_CONFIGURATION configuration"
    echo -e "\n"
    echo -e "All commands:\n"
    echo -e "help wizard branch owner repo poll-for-source-changes configuration\n"
}

# Wizard (8)
wizard() {
  echo "wizard"
  read -r -p "> Please, enter the pipeline’s definitions file path (default: pipeline.json): " INPUT_PATH
  INPUT_PATH="${INPUT_PATH:-./pipeline.json}"
  read -r -p "> Which BUILD_CONFIGURATION name are you going to use: " configuration
  read -r -p "> Enter a GitHub owner/account: " owner
  read -r -p "> Enter a GitHub repository name: " repo
  read -r -p "> Enter a GitHub branch name (default: main): " branch
  branch="${branch:-main}"
  read -r -p "> Do you want the pipeline to poll for changes (true/false) (default: false): " poll_for_source_changes
  poll_for_source_changes="${poll_for_source_changes:-false}"
}

# Manual parsing command line options
while :; do
    case $1 in
        -h|--help)
          help
          exit
          ;;
        -w|--wizard)
          wizard
          break
          ;;
        -b|--branch)
          branch=$2
          shift
          ;;
        -o|--owner)
          owner=$2
          shift
          ;;
        -r|--repo)
          repo=$2
          shift
          ;;
        -p|--poll-for-source-changes)
          poll_for_source_changes=$2
          shift
          ;;
        -c|--configuration)
          configuration=$2
          shift
          ;;
        *)
          break
    esac
    shift
done

# Checking if the file was provided (5)
if ! [ -f "$INPUT_PATH" ]
then
  echo -e "Please provide a path to the pipeline file!\n"
  help
  exit
fi

# Checking if jq is installed (3)
checkJQ() {
  type jq >/dev/null 2>&1
  exitCode=$?

  if [ "$exitCode" -ne 0 ]; then
    echo "'jq' package is not found!"
    exit 1;
  fi
}
checkJQ

replaceSourceConfig() {
  key=$1
  value=$2
  type=$3
  # Checking if the value is set
  if [ -z "$value" ]
  then
    return
  fi
  # Handling string type case
  if [ "$type" == "string" ]
  then
    value="\"$value\""
  fi
  # Replacing the json
  # also checking if the provided key exists (4)
  json=$(jq ".pipeline.stages[].actions[] \
    |= if (.name == \"Source\") \
    then ( \
      if (.configuration.$key) \
      then ( \
        .configuration.$key = $value \
      ) \
      else ( \
        error(\"The '$key' key doesn't exist, exiting\n\") \
      ) \
      end \
    ) \
    else . end" <<< "$json")
  exitCode=$?
  if [ "$exitCode" -ne 0 ]
  then
    exit 1;
  fi
}

json=$(jq . "$INPUT_PATH")
# Removing metadata object (1.1)
json=$(jq "del(.metadata)" <<< "$json")
# Incrementing pipeline version (1.2)
json=$(jq ".pipeline.version = .pipeline.version + 1" <<< "$json")
# Updating the 'Branch', 'Owner', 'Repo' and 'PollForSourceChanges' of 'Source' action (1.3-1.6)
# if any of the options are provided (6)
if [[ -n "$branch" || -n "$owner" || -n "$repo" || -n "$poll_for_source_changes" ]]
then
  branch="${branch:-main}"
  poll_for_source_changes="${poll_for_source_changes:-false}"
  replaceSourceConfig "Branch" "$branch" "string"
  replaceSourceConfig "Owner" "$owner" "string"
  replaceSourceConfig "Repo" "$repo" "string"
  replaceSourceConfig "PollForSourceChanges" "$poll_for_source_changes" "boolean"
fi
# Updating 'EnvironmentVariables' (1.7)
json=$(jq ".pipeline.stages[].actions[].configuration \
    |= if (has(\"EnvironmentVariables\")) \
    then ( \
        .EnvironmentVariables |= gsub(\"{{BUILD_CONFIGURATION value}}\"; \"$configuration\") \
    ) \
    else . end" <<< "$json")
echo "$json" > "$OUTPUT_PATH"
