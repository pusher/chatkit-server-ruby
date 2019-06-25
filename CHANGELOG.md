# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/pusher/chatkit-server-ruby/compare/1.4.0...HEAD)

[1.4.0](https://github.com/pusher/chatkit-server-ruby/compare/1.3.0...1.4.0) - 2019-06-24

### Changed

- Unread counts. No new methods are added, but `getUserRooms` now include `unread_count` and `last_message_at` in the response

## [1.3.0](https://github.com/pusher/chatkit-server-ruby/compare/1.2.0...1.3.0) - 2019-06-18

### Added

- Async deletion methods. `async_delete_user`, `async_delete_room` and `get_delete_status`.
  The `delete_room` and `delete_user` methods should be considered deprecated, and will be removed in a future version.


## [1.2.0](https://github.com/pusher/chatkit-server-ruby/compare/1.1.0...1.2.0) - 2019-03-08

### Added

- `send_multipart_message`, `send_simple_message` and `fetch_multipart_messages` using the new V3 endpoints

### Changed

- all methods except `sendMessage` and `getRoomMessages` uses new V3 endpoints

## [1.1.0](https://github.com/pusher/chatkit-server-ruby/compare/1.0.0...1.1.0) - 2018-11-07

### Additions

- `create_room` and `update_room` accept `custom_data` as part of the `options` hash.

## [1.0.0](https://github.com/pusher/chatkit-server-ruby/compare/0.7.2...1.0.0) - 2018-10-30

### Changes

#### Breaking

- Room IDs are now strings throughout.
- All functions now take a single hash as their sole parameter
- `get_users_by_ids` has been renamed to `get_users_by_id`
- `generate_su_token` now returns a hash with the keys `token` and `expires_in`, to match the return value of `generate_access_token`
- All functions that interact with the API (i.e. everything but authentication methods) either raise a `PusherPlatform::ErrorResponse` or return a hash of the form:

```ruby
{
  status: 200
  headers: {
    ...
  },
  body: {
    ...
  }
}
```

#### Non-breaking

- Bump pusher-platform dependency to 0.11.2
- Unified all errors under a `Chatkit::Error` type

### Additions

- Added the following functionality:
    - `create_room`
    - `update_room`
    - `delete_room`
    - `get_user_rooms`
    - `get_user_joinable_rooms`
    - `add_users_to_room`
    - `remove_users_from_room`
    - `get_user`
    - `update_user`
    - `create_users`
    - `send_message`
    - `delete_message`
    - `update_permissions_for_global_role`
    - `update_permissions_for_room_role`
    - `get_read_cursor`
    - `set_read_cursor`
    - `get_user_read_cursors`
    - `get_room_read_cursors`

- `get_rooms` supports the `include_private` option

### Removals

- Removed `update_permissions_for_role` (replaced by `update_permissions_for_global_role` and `update_permissions_for_room_role`)
- `authenticate_with_request` has been removed as we believe `authenticate` provides an easier to use API

### Fixes

- `get_rooms` now properly paginates using the `from_ts` value provided

## [0.7.2](https://github.com/pusher/chatkit-server-ruby/compare/0.7.1...0.7.2) - 2018-07-20

### Changes

- Bump pusher-platform-ruby dependency to 0.8.2

## [0.7.1](https://github.com/pusher/chatkit-server-ruby/compare/0.7.0...0.7.1) - 2018-05-24

### Changes

- Bump pusher-platform-ruby dependency to 0.8.1

## [0.7.0](https://github.com/pusher/chatkit-server-ruby/compare/0.6.1...0.7.0) - 2018-04-23

### Changes

- Bump pusher-platform-ruby dependency to 0.8.0
- `authenticate` now returns an object like this:

```js
{
    "status": 200,
    "headers": {
        "Some-Header": "some-value"
    },
    "body": {
        "access_token": "an.access.token",
        "token_type": "bearer",
        "expires_in": 86400
    }
}
```

where:

* `status` is the suggested HTTP response status code,
* `headers` are the suggested response headers,
* `body` holds the token payload.

If there's an error with the authentication process then the return value will be the same but with a different `body`. For example:

```js
{
    "status": 422,
    "headers": {
        "Some-Header": "some-value"
    },
    "body": {
        "error": "token_provider/invalid_grant_type",
        "error_description": "The grant_type provided, some-invalid-grant-type, is unsupported"
    }
}
```

- Authentication no longer returns refresh tokens.

If your client devices are running the:

* Swift SDK - (**breaking change**) you must be using version `>= 0.8.0` of [chatkit-swift](https://github.com/pusher/chatkit-swift).
* Android SDK - you won't be affected regardless of which version you are running.
* JS SDK - you won't be affected regardless of which version you are running.

### Additions

- `authenticate_with_request` has been added so if you are using a web server that uses `Rack::Request` objects as the request objects then you can call `authenticate_with_request` like this:

```ruby
auth_data = chatkit.authenticate_with_request(request, { user_id: 'testymctest' })
```

## [0.6.1](https://github.com/pusher/chatkit-server-ruby/compare/0.6.0...0.6.1) - 2018-01-26

### Changes

- Bump pusher-platform-ruby dependency to 0.6.0
