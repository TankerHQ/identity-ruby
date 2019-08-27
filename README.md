# Identity [![Travis][build-badge]][build]

Identity generation in Ruby for the [Tanker SDK](https://tanker.io/docs/latest).

## Installation

This project depends on the [rbnacl](https://github.com/crypto-rb/rbnacl) gem, which requires the [libsodium](https://download.libsodium.org/doc/) cryptographic library.

Before going further, please follow [instructions to install libsodium](https://github.com/crypto-rb/rbnacl/wiki/Installing-libsodium).

Then, add this line to your application's Gemfile:

```ruby
gem 'tanker-identity', git: 'https://github.com/TankerHQ/identity-ruby' #, tag: 'vX.Y.Z'
```

Finally, execute:

    $ bundle

## Usage

```ruby
require 'tanker-identity'

Tanker::Identity.create_identity(app_id, app_secret, user_id)
Tanker::Identity.create_provisional_identity(app_id, email)
Tanker::Identity.get_public_identity(identity)

# if migrating from SDK < 2.0.0
Tanker::Identity.upgrade_user_token(app_id, user_id, user_token) # => identity
```

## Usage example

The server-side pseudo-code below demonstrates a typical flow to safely deliver identities to your users:

```ruby
require 'tanker-identity'

# 1. store these configurations in a safe place
app_id = '<app-id>'
app_secret = '<app-secret>'

# 2. you will typically have methods to check user authentication
def authenticated? # check user is authenticated on the server
def current_user   # current authenticated user

# 3. you will need to add internal methods to store / load identities
def db_store_identity(user_id, identity)
def db_load_identity(user_id)

# 4. finally, add user facing functionality
def tanker_secret_identity(user_id)
  raise 'Not authenticated' unless authenticated?
  raise 'Not authorized' unless current_user.id == user_id

  identity = db_load_identity(user_id)

  if identity.nil?
    identity = Tanker::Identity.create_identity(app_id, app_secret, user_id)
    db_store_identity(user_id, identity)
  end

  identity
end

def tanker_public_identity(user_id)
  raise 'Not authenticated' unless authenticated?

  identity = db_load_identity(user_id)

  raise 'User does not exist or has no identity yet' unless identity

  Tanker::Identity.get_public_identity(identity)
end
```

Read more about identities in the [Tanker documentation](https://docs.tanker.io/latest/).

Check the [examples](https://github.com/TankerHQ/identity-ruby/tree/master/examples/) folder for usage examples.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TankerHQ/identity-ruby.

[build-badge]: https://travis-ci.org/TankerHQ/identity-ruby.svg?branch=master
[build]: https://travis-ci.org/TankerHQ/identity-ruby
