
class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  ## for OPTIONS requests.
  def cors_allow
    add_cors_headers
    render :status => 200, :text => ''
  end

  protected

  def current_user
    current_session.try(:user)
  end

  def logged_in?
    !!current_user
  end

  def current_session
    Session.find
  end

  def require_login
    redirect_to(:new_session) unless logged_in?
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
