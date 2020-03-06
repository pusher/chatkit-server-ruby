# chatkit-server-ruby

[![Twitter](https://img.shields.io/badge/twitter-@Pusher-blue.svg?style=flat)](http://twitter.com/Pusher)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/pusher/chatkit-server-ruby/blob/master/LICENSE.md)
[![Gem Version](https://badge.fury.io/rb/pusher-chatkit-server.svg)](https://badge.fury.io/rb/pusher-chatkit-server)

Ruby server SDK for Pusher Chatkit.

## Installation

```
$ gem install pusher-chatkit-server
```

## Deprecated versions

Versions of the library below [1.0.0](https://github.com/pusher/chatkit-server-ruby/releases/tag/v1.0.0) are deprecated and support for them will soon be dropped.

It is highly recommended that you upgrade to the latest version if you're on an older version. To view a list of changes,
please refer to the [CHANGELOG](CHANGELOG.md).

## Examples

Refer to the `examples` directory. It contains several examples demonstrating all the methods.

## Documentation

Refer to the [docs site](https://docs.pusher.com/chatkit/reference/server-ruby). It documents how to use all methods with examples.


## Running tests
Be sure to run `bundle install` first. Note that if you're running against a production environment, some tests could be destructive.
- Set a `CHATKIT_INSTANCE_LOCATOR` and `CHATKIT_INSTANCE_KEY` in your environment
- Run tests with `rake test`

Tip: to run individual tests, run `rspec spec/client_spec.rb -e "<name of your test>"`

## Release checklist
Best to do a proper PR, rather than releasing from master, as missing one of these steps could cause a broken release.
- Update the CHANGELOG with the changes and new version number
- Update the version number in `chatkit.gemspec`
- Build with `bundle install`
- Commit the `Gemfile.lock`
- Merge upstream, do a Git tag and Git release
- Pull from master and `bundle install`
- Build gem with `gem build chatkit.gemspec`
- Push to [Rubygems](https://rubygems.org/gems/pusher-chatkit-server) with `gem push pusher-chatkit-server-[version].gem`
