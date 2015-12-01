require_relative 'test_helper'

class TestAhoyController < Minitest::Test
  def setup
    controller_class = Class.new
    def controller_class.helper_method(_method_name); end

    def controller_class.before_filter(*_method_name); end
    controller_class.include(Ahoy::Controller)

    @controller = controller_class.new
  end

  def test_track_ahoy_visit
    @mock_tracker = Minitest::Mock.new
    @mock_tracker.expect(:track_visit, nil, [{ defer: true }])
    @controller.instance_variable_set('@ahoy', @mock_tracker)

    @controller.track_ahoy_visit

    @mock_tracker.verify
  end
end
