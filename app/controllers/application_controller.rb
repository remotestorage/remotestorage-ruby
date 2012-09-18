class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user

  def cors_allow
    add_cors_headers
    render :status => 200, :text => ''
  end

  protected

  def current_user
    current_session.try(:user)
  end

  def current_session
    Session.find
  end

  def require_login
    current_user || redirect_to(:new_session)
  end

  def add_cors_headers
    h = {
      'Access-Control-Allow-Methods' => 'GET, PUT, DELETE',
      'Access-Control-Allow-Origin' => request.headers['Origin'] || '*',
      'Access-Control-Allow-Headers' => 'Origin, Authorization, Content-Type, ETag'
    }

    h.each_pair do |k, v|
      headers[k] = v
    end
  end
end
