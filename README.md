# Chatkit Retirement Announcement
We are sorry to say that as of April 23 2020, we will be fully retiring our
Chatkit product. We understand that this will be disappointing to customers who
have come to rely on the service, and are very sorry for the disruption that
this will cause for them. Our sales and customer support teams are available at
this time to handle enquiries and will support existing Chatkit customers as
far as they can with transition. All Chatkit billing has now ceased , and
customers will pay no more up to or beyond their usage for the remainder of the
service. You can read more about our decision to retire Chatkit here:
[https://blog.pusher.com/narrowing-our-product-focus](https://blog.pusher.com/narrowing-our-product-focus).
If you are interested in learning about how you can build chat with Pusher
Channels, check out our tutorials.

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
