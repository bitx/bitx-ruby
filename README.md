# BitX Ruby

Ruby wrapper for the BitX API.

Currently the public API (ticker, orderbook, trades) is wrapped.
TODO: Add the private API.

## Installation

Add this line to your application's Gemfile:

    gem 'bitx-ruby'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitx-ruby

## Usage

```
require 'bitx-ruby'

# Fetch the ticker
BitX.new.ticker('XBTZAR')

# Fetch the order book
BitX.new.orderbook('XBTZAR')

# Fetch the latest trades
BitX.new.trades('XBTZAR')
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
