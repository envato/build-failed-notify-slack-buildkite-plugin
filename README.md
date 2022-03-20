# Build Failed Notify Slack Buildkite Plugin

@'s the creator of the failed build via a mapping file

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - label: ":slack: Notify on fail"
    plugins:
      - envato/build-failed-notify-slack#v1.0.0:
          mapping_file: slack_users.json
          channel: "#my-channel"
```

Mapping files can be downloaded from s3

```yml
steps:
  - label: ":slack: Notify on fail"
    plugins:
      - cultureamp/aws-assume-role#v0.2.0:
          role: "arn:aws:iam::123456789012:role/example-role"
      - envato/build-failed-notify-slack#v1.0.0:
          mapping_file: s3://my-bucket/slack_users.json
          channel: "#my-channel"
```

## Configuration

### `mapping_file` (Required, string)

JSON file with an array of users slack id's and email addresses (email used in Buildkite, appears as `BUILDKITE_BUILD_CREATOR_EMAIL`)

### `channel` (Required, string)

Including the hash, a channel in slack.

## Developing

To run the tests:

```shell
docker-compose run --rm tests
```

To run the linting:

```shell
docker-compose run --rm lint
```