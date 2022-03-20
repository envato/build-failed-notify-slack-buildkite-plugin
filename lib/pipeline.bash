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

  if [[ -f "$mapping_file" ]]; then
    slackId=$(cat "$mapping_file" | jq -r ".[] | select(.email==\"$email\").slackId")
  fi

  if [[ -n "${slackId-}" ]]; then
    creator="<@${slackId-}>"
  fi

  echo "steps: []"
  echo
  echo "notify:"
  echo "  - slack:"
  echo "      channels:"
  echo "        - \"$channel\""
  echo "      message: \"The most recent \`$branch\` branch build by $creator has failed, please take a look.\""
  echo "    if: build.state == \"failed\""
}