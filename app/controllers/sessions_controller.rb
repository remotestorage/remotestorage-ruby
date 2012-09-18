class SessionsController < ApplicationController

  def new
    @session = Session.new(:login => params[:login])
  end

  def create
    @session = Session.new(params[:session])
    if @session.save
      if params[:auth]
        redirect_to new_authorization_url(params[:auth])
      else
        redirect_to :dashboard
      end
    else
      render 'new'
    end
  end

  def destroy
    @session = Session.find(params[:id])
    @session.destroy

    redirect_to :action => 'new'
  end

end
