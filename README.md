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
      - envato/build-failed-notify-slack#v1.1.0:
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
      - envato/build-failed-notify-slack#v1.1.0:
          mapping_file: s3://my-bucket/slack_users.json
          channel: "#my-channel"
```

## Configuration

### `mapping_file` (Required, string)

JSON file with an array of users slack id's and email addresses (email used in Buildkite, appears as `BUILDKITE_BUILD_CREATOR_EMAIL`)

eg.

```json
[
  {
    "email": "me@example.com",
    "slackId": "U1234"
  },
  {
    "email": "other@example.com",
    "slackId": "U5678"
  }
]
```

### `channel` (Required, string)

Including the hash, a channel in slack. 

> [!NOTE]
> The slack channel must be configured to receive notifications with the [Buildkite Builds](https://envato.slack.com/marketplace/AN19RS48G-buildkite-builds) Slack app. Ask IT for help enabling the integration.

## Developing

To run the tests:

```shell
docker-compose run --rm tests
```

To run the linting:

```shell
docker-compose run --rm lint
```
