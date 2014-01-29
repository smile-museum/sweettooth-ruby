require File.expand_path('../../test_helper', __FILE__)

module SweetTooth
  class SpendingTest < Test::Unit::TestCase

    should "create should return a new spending" do
      @mock.expects(:post).once.returns(test_response(test_spending))
      r = SweetTooth::Spending.create
      assert_equal "spe_test_spending", r.id
    end

  end
end
