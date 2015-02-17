# BitX Ruby

Ruby wrapper for the BitX API.

## Rate limits

If rate limits are exceeded BitX will return a 503 error. Make sure your code handles that appropriately.

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
  config.api_key_pin = 'yourapikeypinfrombitx'
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


Connection object

```
  # if you need to access the BitX api with different credentials in a concurrent system, you can use the BitX::Connection object

  #if config changes:
  bit_x = BitX::Connection.new() do |config|
    config.api_key_secret = 'yoursecretkeyfrombitx'
    config.api_key_id = 'yourapiidfrombitx'
    config.api_key_pin = 'yourapikeypinfrombitx'
  end
  bit_x.balance

  #if you want to use a mocked connection
  bitx = BitX::Connection.new(stubbed_connection)
  bitx.tickers


```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Changelog

```
# 0.2.1 - force place order to specify price in integers
# 0.2.0 - adds a connection object to support concurrent systems where the connection or configuration objects may change
# 0.1.0 - adds a number of methods. introduces some breaking changes to existing methods.
  add support for public method *tickers* to get all bitx tickers
  add volume to *ticker* response to be the 24_hour_rolling_volume
  add timestamp to *orderbook* response
  deprecate *balance_for*
  add *balance* to return a list of accounts with balances
  add *new_receive_address*
  add *received_by_address*
  modify *funding_address*
  deprecate *funding_address*
  add *send* method
  add *api_key_pin* config option
  add *create_quote*
  add *exercise_quote*
  add *discard_quote*
  add *view_quote*
  add basic tests
```
