class PasswordChangesController < ApplicationController
  before_filter :require_login

  def new
  end

  def create
    if current_user.update_attributes(params[:user])
      redirect_to :dashboard
    else
      render 'new'
    end
  end
end
