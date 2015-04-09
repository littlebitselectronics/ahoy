module Ahoy
  class Tracker
    attr_reader :request, :controller, :domain

    def initialize(options = {})
      @store = Ahoy::Store.new(options.merge(ahoy: self))
      @controller = options[:controller]
      @request = options[:request] || @controller.try(:request)
      @options = options
      @domain = request.subdomain.present? ? "#{request.subdomain}.#{request.domain}" : request.domain
    end

    def track(name, properties = {}, options = {})
      persisted_event = nil

      unless exclude?
        options = options.dup

        options[:id] = ensure_uuid(options[:id] || generate_id)

        @store.track_event(name, properties, options) do |event|
          persisted_event = event
        end
      end
      persisted_event
    rescue => e
      report_exception(e)
    end

    def track_visit(options = {})
      persisted_visit = nil

      unless exclude?
        if options[:defer]
          set_cookie("ahoy_track", true)
        else
          options = options.dup

          @store.track_visit(options) do |visit|
            persisted_visit = visit
          end
        end
      end
      persisted_visit
    rescue => e
      report_exception(e)
    end

    def check_for_persistence(options = {})
      visit = Visit.find_by(id: options[:visit_id])

      if visit.nil?
        visit = self.track_visit

        if visit.nil?
          ::Honeybadger.notify(
            :error_class   => "Ahoy::Tracker#check_for_persistence",
            :error_message => "Visit nil and unable to be created",
            :parameters    => {
              visit_id: options[:visit_id],
              visitor_id: options[:visitor_id]
            }
          )
        end
      end
    end

    def authenticate(user)
      unless exclude?
        @store.authenticate(user)
      end
      true
    rescue => e
      report_exception(e)
    end

    def visit
      @visit ||= (@store.visit || Visit.new)
    end

    def visit_id
      @visit_id ||= ensure_uuid(existing_visit_id || visit_token)
    end

    def visitor_id
      @visitor_id ||= ensure_uuid(existing_visitor_id || visitor_token)
    end

    def new_visit?
      !existing_visit_id
    end

    def set_visit_cookie
      set_cookie("visit", visit_id, Ahoy.visit_duration) unless migrate_old_visit_cookie
    end

    def set_visitor_cookie
      unless migrate_old_visitor_cookie
        if !existing_visitor_id
          set_cookie("visitor", visitor_id, Ahoy.visitor_duration)
        end
      end
    end

    def user
      @user ||= @store.user
    end

    # TODO better name
    def visit_properties
      @visit_properties ||= Ahoy::VisitProperties.new(request, @options.slice(:api))
    end

    # for ActiveRecordTokenStore only - do not use
    def visit_token
      @visit_token ||= existing_visit_id || (@options[:api] && request.params["visit_token"]) || generate_id
    end

    # for ActiveRecordTokenStore only - do not use
    def visitor_token
      @visitor_token ||= existing_visitor_id || (@options[:api] && request.params["visitor_token"]) || generate_id
    end

    protected

    def set_cookie(name, value, duration = nil)
      cookie = {
        value: value
      }
      cookie[:expires] = duration.from_now if duration
      domain = Ahoy.cookie_domain || Ahoy.domain
      cookie[:domain] = domain if domain
      request.cookie_jar[name] = cookie
    end

    def exclude?
      @store.exclude?
    end

    def report_exception(e)
      begin
        @store.report_exception(e)
      rescue
        # fail-safe
        $stderr.puts "Error reporting exception"
      end
      if Rails.env.development?
        raise e
      end
    end

    def generate_id
      @store.generate_id
    end

    def existing_visit_id
      @existing_visit_id ||= request &&
        (request.headers["Ahoy-Visit"] || request.cookies["visit"])
    end

    def existing_visitor_id
      @existing_visitor_id ||= request &&
        (request.headers["Ahoy-Visitor"] || request.cookies["visitor"])
    end

    def ensure_uuid(id)
      Ahoy.ensure_uuid(id)
    end

    def migrate_old_visitor_cookie
      old_visitor_cookie = request.cookies["ahoy_visitor"]
      new_visitor_cookie = request.cookies["visitor"]

      if old_visitor_cookie.present? && !new_visitor_cookie.present?
        set_cookie("visitor", old_visitor_cookie, Ahoy.visitor_duration)
        return true
      end
      false
    end

    def migrate_old_visit_cookie
      old_visit_cookie = request.cookies["ahoy_visit"]
      new_visit_cookie = request.cookies["visit"]

      if (old_visit_cookie).present? && !new_visit_cookie
        set_cookie("visit", old_visit_cookie, Ahoy.visit_duration)
        return true
      end
      false
    end
  end
end
