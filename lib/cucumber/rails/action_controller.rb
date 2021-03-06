ActionController::Base.class_eval do
  cattr_accessor :allow_rescue
  
  alias_method :rescue_action_without_bypass, :rescue_action

  def rescue_action(exception)
    if ActionController::Base.allow_rescue
      rescue_action_without_bypass(exception)
    else
      raise exception
    end
  end
end

begin
  ActionController::Failsafe.class_eval do
    alias_method :failsafe_response_without_bypass, :failsafe_response
  
    def failsafe_response(exception)
      raise exception
    end
  end
rescue NameError # Failsafe was introduced in Rails 2.3.2
  ActionController::Dispatcher.class_eval do
    def self.failsafe_response(output, status, exception = nil)
      raise exception
    end
  end
end

Before('@allow-rescue') do
  ActionController::Base.allow_rescue = true
end