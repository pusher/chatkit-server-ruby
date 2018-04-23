# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/pusher/chatkit-server-ruby/compare/0.6.1...HEAD)

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

_.. prehistory_
