require_relative 'test_helper'

class Ahoy::Store < Ahoy::Stores::BaseStore
  # The visit_tracker options is for testing purposes only.
  # It helps to inject a mock for whom we set expectations.
  def initialize(options)
    super(options)

    @visit_tracker = options[:visit_tracker]
  end

  def track_visit(options)
    @visit_tracker.track_visit(options)
  end
end


class TestAhoyTracker < Minitest::Test
  def setup
    @mock_request = MiniTest::Mock.new
    @mock_request.expect(:subdomain, nil)
    @mock_request.expect(:domain, 'domain')
    @mock_request.expect(:user_agent, 'chrome')
    @mock_request.expect(:headers, {})

    @mock_visit_tracker = MiniTest::Mock.new

    @tracker = Ahoy::Tracker.new(request: @mock_request,
                                 visit_tracker: @mock_visit_tracker)
  end

  def test_track_visit_when_not_visit
    @mock_request.expect(:cookies, { 'visit' => 'whatever' })
    @mock_visit_tracker.expect(:track_visit, true, [ { new_visit: false } ])

    @tracker.track_visit

    @mock_visit_tracker.verify
  end

  def test_track_visit_when_new_visit
    @mock_request.expect(:cookies, {})
    @mock_visit_tracker.expect(:track_visit, true, [ { new_visit: true } ])

    @tracker.track_visit

    @mock_visit_tracker.verify
  end

end
