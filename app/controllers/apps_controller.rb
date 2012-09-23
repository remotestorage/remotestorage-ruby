class AppsController < ApplicationController

  before_filter :require_login

  before_filter :fetch_app, :only => [:edit, :update, :start]

  def index
    @apps = collection
  end

  def new
    @app = collection.new
  end

  def create
    @app = collection.new(params[:app])
    if @app.save
      redirect_to :apps
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @app.update_attributes(params[:app])
      redirect_to :apps
    else
      render 'edit'
    end
  end

  private

  def collection
    current_user.apps
  end

  def fetch_app
    @app = collection.find(params[:id])
  end
end
