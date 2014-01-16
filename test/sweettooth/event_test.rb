require File.expand_path('../../test_helper', __FILE__)

module SweetTooth
  class EventTest < Test::Unit::TestCase

    should "create should return a new event" do
      @mock.expects(:post).once.returns(test_response(test_event))
      c = SweetTooth::Event.create
      assert_equal "eve_test_event", c.id
    end

  end
end
