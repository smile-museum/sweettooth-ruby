require File.expand_path('../../test_helper', __FILE__)

module SweetTooth
  class RedemptionTest < Test::Unit::TestCase

    should "create should return a new redemption" do
      @mock.expects(:post).once.returns(test_response(test_redemption))
      r = SweetTooth::Redemption.create
      assert_equal "red_test_redemption", r.id
    end

  end
end
