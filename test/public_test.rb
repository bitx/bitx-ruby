require "minitest/pride"
require "minitest/autorun"
require_relative "../lib/bitx.rb"

  module BitX
    def self.conn
     stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        # ticker
        stub.get('/api/1/ticker?pair=XBTZAR') {[200, {}, '{
  "ask": "1050.00",
  "timestamp": 1366224386716,
  "bid": "924.00",
  "rolling_24_hour_volume": "12.52",
  "last_trade": "950.00"
}']}
        stub.get('/api/1/ticker?pair=XBTXRP') {[200, {}, '{
    "error": "Invalid currency pair.",
    "error_code": "ErrInvalidPair"
}']}
        stub.get('/api/1/ticker?pair=xbtzar') {[200, {}, '{
    "error": "Invalid currency pair.",
    "error_code": "ErrInvalidPair"
}']}
        stub.get('/api/1/ticker?pair=ZARXBT') {[500, {}, 'Internal Server Error']}


        # tickers
        stub.get('/api/1/tickers') {[200, {}, '{
  "tickers": [
    {
      "timestamp": 1405413955793,
      "bid": "6801.00",
      "ask": "6900.00",
      "last_trade": "6900.00",
      "rolling_24_hour_volume": "12.455579",
      "pair":"XBTZAR"
    },
    {
      "timestamp": 1405413955337,
      "bid": "5000.00",
      "ask":"6968.00",
      "last_trade": "6830.00",
      "rolling_24_hour_volume": "0.00",
      "pair":"XBTNAD"
    }
  ]
}']}

        # orderbook
        stub.get('/api/1/orderbook?pair=XBTZAR') {[200, {}, '{
  "asks": [
    {
      "volume": "0.10",
      "price": "1180.00"
    },
    {
      "volume": "0.15",
      "price": "2000.00"
    }
  ],
  "bids": [
    {
      "volume": "0.10",
      "price": "1100.00"
    },
    {
      "volume": "0.10",
      "price": "1000.00"
    },
    {
      "volume": "0.10",
      "price": "900.00"
    }
  ],
  "timestamp": 1366305398592,
  "currency": "ZAR"

}']}

        # trades
        stub.get('/api/1/trades?pair=XBTZAR') {[200, {}, '{
  "trades": [
    {
      "volume": "0.10",
      "timestamp": 1366052621774,
      "price": "1000.00"
    },
    {
      "volume": "1.20",
      "timestamp": 1366052620770,
      "price": "1020.50"
    }
  ]
}']}
      end

      Faraday.new do |faraday|
        faraday.adapter :test, stubs
      end
    end
  end

  class TestMeme < Minitest::Test

    #def setup; end

    def test_ticker
      ticker = BitX.ticker('XBTZAR')
      assert_equal ticker[:volume], '12.52'

      err = assert_raises(BitX::Error) {
        BitX.ticker('XBTXRP')
      }
      assert_equal err.message, 'BitX error: Invalid currency pair.'

      err = assert_raises(BitX::Error) {
        BitX.ticker('xbtzar')
      }
      assert_equal err.message, 'BitX error: Invalid currency pair.'

      err = assert_raises(BitX::Error) {
        BitX.ticker('ZARXBT')
      }
      assert_equal err.message, 'BitX error: 500'
    end

    def test_tickers
      tickers = BitX.tickers
      assert_equal tickers.size, 2
      assert_equal tickers.first[:pair], 'XBTZAR'
      assert_equal tickers.first[:ask], 6900.00
      assert_equal tickers.first[:volume], "12.455579"

      assert_equal tickers.last[:volume], "0.00"
      assert_equal tickers.last[:bid], 5000
    end

    def test_orderbook
      ob = BitX.orderbook('XBTZAR')
      assert_equal ob[:bids].size, 3
      assert_equal ob[:bids].first[:price], 1100

      assert_equal ob[:asks].size, 2
      assert_equal ob[:asks].last[:volume], 0.15
      assert_equal ob[:timestamp], Time.at(1366305398)
    end

    def test_trades
      trades = BitX.trades('XBTZAR')
      assert_equal trades.size, 2
      assert_equal trades.first[:timestamp], Time.at(1366052621)
      assert_equal trades.last[:volume], 1.2
      assert_equal trades.last[:price], 1020.5
      assert_operator trades.first[:timestamp], :>=, trades.last[:timestamp]
    end
  end

