#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following line to debug stub failures
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty


@test "Uploading the contents" {
  stub buildkite-agent "pipeline upload : echo done"
  
  run "$PWD/hooks/command"

  assert_success
  assert_output --partial "Contents of notify pipeline"
  assert_output --partial "Uploading notify pipeline"

  unstub buildkite-agent
}