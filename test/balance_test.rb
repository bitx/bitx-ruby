require "minitest/pride"
require "minitest/autorun"
require_relative "../lib/bitx.rb"

  module BalanceStubs
    def self.conn
     stubs = Faraday::Adapter::Test::Stubs.new do |stub|

      stub.get('/api/1/balance') {[ 200, {},
              '{
  "balance": [
    {
      "account_id": "1224342323",
      "asset": "XBT",
      "balance": "1.012423",
      "reserved": "0.01",
      "unconfirmed": "0.421"
    },
    {
      "account_id": "2997473",
      "asset": "ZAR",
      "balance": "1000.00",
      "reserved": "0.00",
      "unconfirmed": "0.00"
    }
  ]
}']}

      end

      Faraday.new do |faraday|
        faraday.adapter :test, stubs
      end
    end
  end

  class TestBalance < Minitest::Test

    def test_balance
      BitX.set_conn(BalanceStubs.conn)

      r = BitX.balance
      assert_equal r.first[:reserved], 0.01
      assert_equal r.first[:available], r.first[:balance] - r.first[:reserved]
      assert_equal r.first[:unconfirmed], 0.421
      assert_equal r.first[:asset], 'XBT'
      assert_equal r.last[:account_id], '2997473'
    end

    def test_connection_balance
      r = BitX::Connection.new(BalanceStubs.conn).balance
      assert_equal r.first[:reserved], 0.01
      assert_equal r.first[:available], r.first[:balance] - r.first[:reserved]
      assert_equal r.first[:unconfirmed], 0.421
      assert_equal r.first[:asset], 'XBT'
      assert_equal r.last[:account_id], '2997473'
    end
  end