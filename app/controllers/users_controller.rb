class UsersController < ApplicationController

  before_filter :require_login, :except => [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to :new_session
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = "Updated data"
      redirect_to :edit
    else
      flash[:error] = "Validation failed"
      render "edit"
    end
  end

end
