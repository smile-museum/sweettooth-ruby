require File.expand_path('../../test_helper', __FILE__)

module SweetTooth
  class ActivityTest < Test::Unit::TestCase

    should "create should return a new activity" do
      @mock.expects(:post).once.returns(test_response(test_activity))
      c = SweetTooth::Activity.create
      assert_equal "act_test_activity", c.id
    end

  end
end
