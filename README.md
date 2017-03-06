# manifoldco_signature

Verify signed HTTP requests from Manifold.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'manifoldco_signature'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install manifoldco_signature

## Usage

```ruby
require 'manifoldco_signature'

# initialize once per application
verifier = ManifoldcoSignature::Verifier.new

# verify a Rack::Request. returns a boolean.
verifier.valid? request
```
