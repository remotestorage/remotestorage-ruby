class RootController < ApplicationController

  def index
    if logged_in?
      redirect_to :dashboard
    else
      @title = "Storage"
      @session = Session.new
    end
  end

end
