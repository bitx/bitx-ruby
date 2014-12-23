require "minitest/pride"
require "minitest/autorun"
require_relative "../lib/bitx.rb"

  module QuoteStubs
    def self.conn
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|

        stub.post('/api/1/quotes', {:type=>"BUY", :pair=>"XBTZAR", :base_amount=>0.1}) {[ 200, {},
              '{
  "id": "1324",
  "type": "BUY",
  "pair": "XBTZAR",
  "base_amount": "0.1",
  "counter_amount": "1234.24",
  "created_at": 1418377612342,
  "expires_at": 1418377912342,
  "discarded": false,
  "exercised": false
}']}


        stub.post('/api/1/quotes', {:type=>"SELL", :pair=>"XBTZAR", :base_amount=>0.1}) {[ 200, {},
              '{
  "id": "1325",
  "type": "SELL",
  "pair": "XBTZAR",
  "base_amount": "0.1",
  "counter_amount": "1200.00",
  "created_at": 1418377612342,
  "expires_at": 1418377912342,
  "discarded": false,
  "exercised": false
}']}

        stub.put('/api/1/quotes/1324') {[ 200, {},
        '{
  "id": "1324",
  "type": "BUY",
  "pair": "XBTZAR",
  "base_amount": "0.1",
  "counter_amount": "1234.24",
  "created_at": 1418377612342,
  "expires_at": 1418377912342,
  "discarded": false,
  "exercised": true
}']}

        stub.get('/api/1/quotes/1325') {[ 200, {},
              '{
  "id": "1325",
  "type": "SELL",
  "pair": "XBTZAR",
  "base_amount": "0.1",
  "counter_amount": "1200.00",
  "created_at": 1418377612342,
  "expires_at": 1418377912342,
  "discarded": false,
  "exercised": false
}']}

        stub.delete('/api/1/quotes/1325') {[ 200, {},
              '{
  "id": "1325",
  "type": "SELL",
  "pair": "XBTZAR",
  "base_amount": "0.1",
  "counter_amount": "1200.00",
  "created_at": 1418377612342,
  "expires_at": 1418377912342,
  "discarded": true,
  "exercised": false
}']}


      end

      Faraday.new do |faraday|
        faraday.adapter :test, stubs
      end
    end
  end

  class TestQuotes < Minitest::Test

    def setup
      BitX.set_conn(QuoteStubs.conn)
    end

    def test_post_buy
      r = BitX.create_quote('XBTZAR', 0.1, 'BUY')
      assert_equal '1324', r[:id]
      assert_equal false, r[:exercised]
      assert_equal false, r[:discarded]
    end

    def test_post_sell
      r = BitX.create_quote('XBTZAR', 0.1, 'SELL')
      assert_equal '1325', r[:id]
      assert_equal false, r[:exercised]
      assert_equal false, r[:discarded]
    end

    def test_put_exercise
      r = BitX.exercise_quote('1324')
      assert_equal '1324', r[:id]
      assert_equal true, r[:exercised]
      assert_equal false, r[:discarded]
    end

    def test_get_view
      r = BitX.view_quote('1325')
      assert_equal '1325', r[:id]
      assert_equal false, r[:exercised]
      assert_equal false, r[:discarded]
    end


    def test_delete_discard
      r = BitX.discard_quote('1325')
      assert_equal '1325', r[:id]
      assert_equal false, r[:exercised]
      assert_equal true, r[:discarded]
    end
  end