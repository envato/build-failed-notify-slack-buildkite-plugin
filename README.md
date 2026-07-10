# Build Failed Notify Slack Buildkite Plugin

Buildkite has a notifications feature that can notify channels in slack about build status. The problem is that it's missing a mapping to the build creator's slack ID.

This plugin uses the [notifications feature](https://buildkite.com/docs/pipelines/notifications) and a mapping file to @at the creator of a failed build.

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - label: ":slack: Notify on fail"
    if: build.branch == "main"
    plugins:
      - envato/build-failed-notify-slack#v1.2.0:
          mapping_file: slack_users.json
          channel: "#my-channel"
```

Mapping files can be downloaded from s3

```yml
steps:
  - label: ":slack: Notify on fail"
    if: build.branch == "main"
    plugins:
      - cultureamp/aws-assume-role#v0.2.0:
          role: "arn:aws:iam::123456789012:role/example-role"
      - envato/build-failed-notify-slack#v1.2.0:
          mapping_file: s3://my-bucket/slack_users.json
          channel: "#my-channel"
```

## Configuration

### `mapping_file` (Required, string)

JSON file with an array of users' Slack IDs and the identities used to look them up. The build creator is matched against `email` first (the email used in Buildkite, appears as `BUILDKITE_BUILD_CREATOR_EMAIL`), falling back to a case-insensitive match on `github` (the username in `BUILDKITE_BUILD_CREATOR`).

Each entry requires `slackId`, plus at least one of `email` or `github`.

eg.

```json
[
  {
    "email": "me@example.com",
    "github": "dev1",
    "slackId": "U1234"
  },
  {
    "email": "other@example.com",
    "github": "dev2",
    "slackId": "U5678"
  }
]
```

### `channel` (Required, string)

Including the hash, a channel in slack. 

> [!NOTE]
> The slack channel must be configured to receive notifications with the [Buildkite Builds](https://slack.com/marketplace/AN19RS48G) Slack app. More support for integrating with Buildkite can be found in their [documentation](https://buildkite.com/docs/pipelines/integrations/other/slack)

### `notify_on_state_change` (Optional, boolean)

Defaults to `false`, which notifies on every failed build (`build.state == "failed"`).

When set to `true`, the plugin instead notifies only on state _transitions_, using the [`pipeline.started_failing` and `pipeline.started_passing` conditionals](https://buildkite.com/docs/pipelines/configure/notifications#conditional-notifications): a message when a passing pipeline starts failing, and a "now passing again" message when it recovers.

```yml
steps:
  - label: ":slack: Notify on state change"
    if: build.branch == "main"
    plugins:
      - envato/build-failed-notify-slack#v1.2.0:
          mapping_file: slack_users.json
          channel: "#my-channel"
          notify_on_state_change: true
```

> [!NOTE]
> The `pipeline.started_failing` and `pipeline.started_passing` conditionals require the [Slack Workspace](https://buildkite.com/docs/pipelines/integrations/notifications/slack-workspace) notification service.

## Developing

To run the tests:

```shell
docker-compose run --rm tests
```

To run the linting:

```shell
docker-compose run --rm lint
```
