#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following line to debug stub failures
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "looks up the slackId based on email in a json file" {
  export BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_CHANNEL="#my-channel"
  export BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_MAPPING_FILE=tests/fixture.json
  export BUILDKITE_BUILD_CREATOR_EMAIL=me@example.com
  export BUILDKITE_BUILD_CREATOR=me
  export BUILDKITE_BRANCH=main

  run "$PWD/hooks/command"

  assert_success
  assert_output << EOM
steps: []

notify:
  - slack:
      channels:
        - "#my-channel"
      message: "The most recent \`main\` branch build by <@U1234> has failed, please take a look."
    if: build.state == "failed"
EOM
}

@test "looks up the slackId based on email in a json file on s3" {
  export BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_CHANNEL="#my-channel"
  export BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_MAPPING_FILE=s3://source/fixture.json
  export BUILDKITE_BUILD_CREATOR_EMAIL=me@example.com
  export BUILDKITE_BUILD_CREATOR=me
  export BUILDKITE_BRANCH=main

  stub mktemp ": echo tests/fixture.json"
  stub aws "s3 cp s3://source/fixture.json tests/fixture.json : echo done"

  run "$PWD/hooks/command"

  assert_success
  assert_output << EOM
steps: []

notify:
  - slack:
      channels:
        - "#my-channel"
      message: "The most recent \`main\` branch build by <@U1234> has failed, please take a look."
    if: build.state == "failed"
EOM
  
  stub aws
}

@test "can gracefully fail the lookup" {
  export BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_CHANNEL="#my-channel"
  export BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_MAPPING_FILE=tests/fixture.json
  export BUILDKITE_BUILD_CREATOR_EMAIL=not-exist@example.com
  export BUILDKITE_BUILD_CREATOR="Some One"
  export BUILDKITE_BRANCH=main

  run "$PWD/hooks/command"

  assert_success
  assert_output << EOM
steps: []

notify:
  - slack:
      channels:
        - "#my-channel"
      message: "The most recent \`main\` branch build by Some One has failed, please take a look."
    if: build.state == "failed"
EOM
}

@test "can gracefully fail when file missing" {
  export BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_CHANNEL="#my-channel"
  export BUILDKITE_PLUGIN_BUILD_FAILED_NOTIFY_SLACK_MAPPING_FILE=not-real.json
  export BUILDKITE_BUILD_CREATOR_EMAIL=not-exist@example.com
  export BUILDKITE_BUILD_CREATOR="Some One"
  export BUILDKITE_BRANCH=main

  run "$PWD/hooks/command"

  assert_success
  assert_output << EOM
steps: []

notify:
  - slack:
      channels:
        - "#my-channel"
      message: "The most recent \`main\` branch build by Some One has failed, please take a look."
    if: build.state == "failed"
EOM
}