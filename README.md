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
  config.api_key_id = 'yourapiidfrombitx'
end

# Your Bitcoin balance
BitX.balance_for 'XBT'

# Your Rand balance
BitX.balance_for 'ZAR'

# List your orders trading Bitcoin for Rand
BitX.list_orders 'XBTZAR'

# Place a new order
# BitX::ORDERTYPE_BID / BitX::ORDERTYPE_ASK
volume = '0.01'
price = '10000'
BitX.post_order(BitX::ORDERTYPE_BID, volume, price, 'XBTZAR')


#alternatively, if you need to change the api_key during the program you can pass options to the private methods specifying the :api_key_secret and :api_key_id
BitX.balance_for('XBT', {api_key_secret: 'yoursecretkeyfrombitx', api_key_id: 'yourapiidfrombitx'})




```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
