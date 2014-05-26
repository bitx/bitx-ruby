# BitX Ruby

Ruby wrapper for the BitX API.

Currently the public API (ticker, orderbook, trades) is wrapped.
TODO: Add the private API.

## Installation

Add this line to your application's Gemfile:

    gem 'bitx'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bitx

## Usage

```
require 'bitx'

```
Public API usage

```

# Fetch the ticker
BitX.ticker('XBTZAR')

# Fetch the order book
BitX.orderbook('XBTZAR')

# Fetch the latest trades
BitX.trades('XBTZAR')

```

Private API usage

```
# In a configure block somewhere in your app init:
BitX.configure do |config|
  config.api_key_secret = 'yoursecretkeyfrombitx'
  config.api_key_id = 'yoursecretidfrombitx'
end

# Your Bitcoin balance
BitX.balance_for 'XBT'

# Your Rand balance
BitX.balance_for 'ZAR'

# List your orders trading Bitcoin for Rand
BitX.list_orders 'XBTZAR'

# Place a new order
order_type = 'BID' # or 'ASK'
volume = '0.01'
BitX.post_order(order_type, volume, price, 'XBTZAR')



```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
