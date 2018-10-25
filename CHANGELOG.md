# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/pusher/chatkit-server-ruby/compare/0.7.2...HEAD)


### Changes

- *Breaking* Room IDs are now strings throughout.
- *Breaking:* All functions now take a single hash as their sole parameter
- *Breaking:* `get_users_by_ids` has been renamed to `get_users_by_id`
- *Breaking:* `generate_su_token` now returns a hash with the keys `token` and `expires_in`, to match the return value of `generate_access_token`
- *Breaking*: All functions that interact with the API (i.e. everything but authentication methods) either raise a `PusherPlatform::ErrorResponse` or return a hash of the form:

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

- Bump pusher-platform dependency to 0.11.1
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
