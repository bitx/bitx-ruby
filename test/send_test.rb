require "minitest/pride"
require "minitest/autorun"
require_relative "../lib/bitx.rb"

  module SendStubs
    def self.conn
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|
        # send

        stub.post('/api/1/send') {[ 200, {},
              '{"success":true}']}

      end

      Faraday.new do |faraday|
        faraday.adapter :test, stubs
      end
    end
  end

  class TestSend < Minitest::Test

    def setup_module
      BitX.set_conn(SendStubs.conn)
    end
    def setup_connection
      BitX::Connection.new(SendStubs.conn)
    end

    def test_send
      #BitX.send(amount, address, currency='XBT', description='', message='', pin=nil)
      setup_module
      r = BitX.send(1, 'mockaddress')
      assert_equal r[:success], true
    end
    def test_connection_send
      r = setup_connection.send(1, 'mockaddress')
      assert_equal r[:success], true
    end
  end