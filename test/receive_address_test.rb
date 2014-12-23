require "minitest/pride"
require "minitest/autorun"
require_relative "../lib/bitx.rb"

  module ReceiveAddressStubs
    def self.conn
     stubs = Faraday::Adapter::Test::Stubs.new do |stub|



      stub.get('/api/1/funding_address?address=supersecretotherbicoinwallet&asset=XBT') {[ 200, {},
              '{
  "asset": "XBT",
  "address": "supersecretotherbicoinwallet",
  "total_received": "929.23001",
  "total_unconfirmed": "0.30"
}']}


      stub.get('/api/1/funding_address?asset=XBT') {[ 200, {},
              '{
  "asset": "XBT",
  "address": "B1tC0InExAMPL3fundIN6AdDreS5t0Use1",
  "total_received": "1.234567",
  "total_unconfirmed": "0.00"
}']}

      stub.post('/api/1/funding_address') {[ 200, {},
              '{
  "asset": "XBT",
  "address": "B1tC0InExAMPL3fundIN6AdDreS5t0Use2",
  "total_received": "0.00",
  "total_unconfirmed": "0.00"
}']}

      end

      Faraday.new do |faraday|
        faraday.adapter :test, stubs
      end
    end
  end

  class TestReceiveAddress < Minitest::Test

    def setup
      BitX.set_conn(ReceiveAddressStubs.conn)
    end

    def test_get_receive_address
      r = BitX.received_by_address
      assert_equal r[:total_received], "1.234567"
      assert_equal r[:total_unconfirmed], "0.00"
      assert_equal r[:address], 'B1tC0InExAMPL3fundIN6AdDreS5t0Use1'
      assert_equal r[:asset], 'XBT'
    end

    def test_new_receive_address
      r = BitX.new_receive_address
      assert_equal r[:total_received], "0.00"
      assert_equal r[:total_unconfirmed], "0.00"
      assert_equal r[:address], 'B1tC0InExAMPL3fundIN6AdDreS5t0Use2'
      assert_equal r[:asset], 'XBT'
    end

    def test_specify_address
      r = BitX.received_by_address({address: 'supersecretotherbicoinwallet'})
      assert_equal r[:total_received], "929.23001"
      assert_equal r[:total_unconfirmed], "0.30"
      assert_equal r[:address], 'supersecretotherbicoinwallet'
      assert_equal r[:asset], 'XBT'
    end
  end