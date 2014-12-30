require "minitest/pride"
require "minitest/autorun"
require_relative "../lib/bitx.rb"

  module WithdrawalStubs
    def self.conn
      stubs = Faraday::Adapter::Test::Stubs.new do |stub|

        stub.get('/api/1/withdrawals') {[ 200, {},
              '{
  "withdrawals": [
    {
      "status": "PENDING",
      "id": "2221"
    },
    {
      "status": "COMPLETED",
      "id": "1121"
    }
  ]
}']}


        stub.post('/api/1/withdrawals', {type:"ZAR_EFT", amount:1000}) {[ 200, {},
              '{
  "status": "PENDING",
  "id": "1212"
}']}



        stub.get('/api/1/withdrawals/1212') {[ 200, {},
              '{
  "status": "COMPLETED",
  "id": "1212"
}']}

        stub.delete('/api/1/withdrawals/1215') {[ 200, {},
              '{
  "status": "CANCELLED",
  "id": "1215"
}']}


      end

      Faraday.new do |faraday|
        faraday.adapter :test, stubs
      end
    end
  end

  class TestWithdrawals < Minitest::Test

    def setup_module
      BitX.set_conn(WithdrawalStubs.conn)
    end
    def setup_connection
      BitX::Connection.new(WithdrawalStubs.conn)
    end

    def test_list
      setup_module
      r = BitX.withdrawals
      assert_equal r.size, 2
    end
    def test_connection_list
      r = setup_connection.withdrawals
      assert_equal r.size, 2
    end

    def test_withdraw
      setup_module
      r = BitX.withdraw('ZAR_EFT', 1000)
      assert_equal r[:status], 'PENDING'
      assert_equal r[:id], '1212'
    end
    def test_connection_withdraw
      r = setup_connection.withdraw('ZAR_EFT', 1000)
      assert_equal r[:status], 'PENDING'
      assert_equal r[:id], '1212'
    end

    def test_view_withdrawal
      setup_module
      r = BitX.withdrawal('1212')
      assert_equal r[:status], 'COMPLETED'
      assert_equal r[:id], '1212'
    end
    def test_connection_view_withdrawal
      r = setup_connection.withdrawal('1212')
      assert_equal r[:status], 'COMPLETED'
      assert_equal r[:id], '1212'
    end

    def test_cancel_withdrawal
      setup_module
      r = BitX.cancel_withdrawal('1215')
      assert_equal r[:status], 'CANCELLED'
      assert_equal r[:id], '1215'
    end
    def test_connection_cancel_withdrawal
      r = setup_connection.cancel_withdrawal('1215')
      assert_equal r[:status], 'CANCELLED'
      assert_equal r[:id], '1215'
    end

  end