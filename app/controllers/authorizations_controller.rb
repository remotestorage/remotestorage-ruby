class AuthorizationsController < ApplicationController

  before_filter :require_login

  helper_method :auth_params

  def index
    @authorizations = collection
  end

  def new
    if auth_params[:login] && auth_params[:login] != current_user.login
      render 'logout_first' and return
    end
    if @authorization = collection.recover(auth_params)
      redirect_to @authorization.token_redirect_uri
    else
      @authorization = collection.new(auth_params)
    end
  end

  def create
    @authorization = collection.new(params[:authorization])
    if @authorization.save
      redirect_to @authorization.token_redirect_uri
    else
      render 'new'
    end
  end

  def destroy
    @authorization = collection.find(params[:id])
    if @authorization
      @authorization.destroy
    end
    redirect_to :action => 'index'
  end

  private

  def collection
    current_user.authorizations
  end

  def auth_params
    return {
      :scope => params[:scope],
      :redirect_uri => params[:redirect_uri],
      :login => params[:login]
    }
  end

  def require_login
    current_user || redirect_to(new_session_url(:auth => auth_params))
  end

end
