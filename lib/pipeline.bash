#!/bin/bash

set -euo pipefail

function pipeline() {
  mapping_file="${BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_MAPPING_FILE-}"

  if [[ $mapping_file == s3://* ]] ;then
    tmp_file=$(mktemp)
    aws s3 cp "$mapping_file" "$tmp_file" &> /dev/null
    mapping_file="$tmp_file"
  fi

  channel="${BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_CHANNEL-}"
  email="${BUILDKITE_BUILD_CREATOR_EMAIL:-unknown}"
  creator="${BUILDKITE_BUILD_CREATOR:-unknown}"
  branch="${BUILDKITE_BRANCH:-main}"
  notify_on_state_change="${BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_NOTIFY_ON_STATE_CHANGE:-false}"

  if [[ -f "$mapping_file" ]]; then
    # Lookup the email address first, fallback to a case insensitive github username match
    slackId=$(jq -r --arg email "$email" --arg github "$creator" '.[] | select(.email==$email or (.github // "" | ascii_downcase)==($github | ascii_downcase)).slackId' < "$mapping_file")
  fi

  if [[ -n "${slackId-}" ]]; then
    creator="<@${slackId-}>"
  fi

  echo "steps: []"
  echo
  echo "notify:"

  if [[ "$notify_on_state_change" == "true" ]]; then
    notify_slack "The most recent \`$branch\` branch build by $creator has started failing, please take a look." "pipeline.started_failing"
    notify_slack "The most recent \`$branch\` branch build by $creator is now passing again." "pipeline.started_passing"
  else
    notify_slack "The most recent \`$branch\` branch build by $creator has failed, please take a look." "build.state == \"failed\""
  fi
}

# Emit a single slack notify entry with the given message and if condition.
function notify_slack() {
  echo "  - slack:"
  echo "      channels:"
  echo "        - \"$channel\""
  echo "      message: \"$1\""
  echo "    if: $2"
}