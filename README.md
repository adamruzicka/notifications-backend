# README

## Usage

The main entry point to send messages is a predefined Kafka topic: `notifications.outbox`. Messages from that topic would be processed by notifications backend and sent to different services according to user's preferences.

## Architecture

This is a microservice responsible for dispatching preformatted notifications to
different _endpoints_.

### Components

*Message*: A JSON payload with predefined fields: `Application`, `Event type`,
`Severity`, `Message` and `Timestamp`.

*Dispatcher*: Component that is responsible for receiving incoming _messages_ and
deciding (based on _filters_) which _endpoint_ should receive the message.

*Filter*: A combination of `Application`, `Event type` and `Severity` sets that
will be compared against the _message_ received. Once there is a match,
_endpoints_ associated with this filter record would be triggered.

*Endpoint*: A set of properties that would be enough to initiate a web request
to a URL (which is also part of the properties) of a notification service. Good
examples for such services would be slack, sms senders e.t.c.

### Basic flow
The process starts when a message arrives on `notifications.outbox` Kafka topic.
This message is passed to a *dispatcher*.

Dispatcher is responsible to find out
which _endpoints_ should be triggered. Once the _endpoints_ were identified,
an ActiveJob is fired for each _endpoint_ with details of the message to
send and _endpoint_ properties.

The job is responsible to initiate a web request with _endpoint_'s details,
format the _message_ to fit into _endpoint_'s API and make sure the message has
arrived to the recipient (_endpoint_).

## Development setup

Start from cloning this repository

``` sh
git clone https://github.com/RedHatInsights/notifications-backend.git
```

Install all relevant gems

``` sh
bundle install
```

### Spin up docker containers
Make sure you have working docker and [docker-compose](https://docs.docker.com/compose/install/) already set up.

From project's root you can simply run

``` sh
bin/setup_dev
```
it will spin up zookeper, kafka and redis containers ready and waiting for connections.

For more details look at `docker/docker-compose.yml`.


### Start listeners

To start kafka listener run

``` sh
racecar JobCreatorConsumer
```

To start resque job consumer run
``` sh
QUEUE=unsorted_notifications rake environment resque:work
```

### Inject test messages

There is a rake task to inject messages into a dev setup:

``` sh
rake notifications:send
```
add `--help` to see more options.

### PG extensions

This project uses UUID-typed columns, which relies on `pgcrypto` extension which may not be shipped with PostgreSQL by default. On Fedora this extension lives in the `postgresql-contrib` package. Official postgres docker image come bundled with this extension.

## Application registration

```yaml
---
application:
  name: $APPLICATION_NAME
  title: $APPLICATION_TITLE
event_types:
  - id: $EVENT_TYPE_1_ID
    name: $EVENT_TYPE_1_NAME
    title: $EVENT_TYPE_1_TITLE
    levels: {} # This event type has no levels
  - id: $EVENT_TYPE_2_ID
    name: $EVENT_TYPE_2_NAME
    title: $EVENT_TYPE_2_TITLE
    levels:
      - id: $LEVEL_1_ID
        name: $LEVEL_1_NAME
        title: $LEVEL_1_TITLE
      - id: $LEVEL_2_ID
        name: $LEVEL_2_NAME
        title: $LEVEL_2_TITLE
```

`${$THING}_NAME`: the identifier used to match the application in the incoming messages
`${$THING}_TITLE`: the string displayed in the UI as a label
`${$THING}_ID`: An id uniquely identifying the `$THING` within the application in case the application wants to add/modify/remove the `$THING`

If an application wishes to send messages through us, it should send us the definition of all its types when it starts and later anytime the definition changes.

Once an application is registered, it can change its title, but not its name. A registered application can freely change (add, modify, remove) any things scoped under it.

For event types and levels, the entries in UI will most likely be displayed in the order they were provided in the registration message.

Levels are a generalization of what previously was severity. An event type can have 0-1 additional fields which may have event-type specific meaning.
