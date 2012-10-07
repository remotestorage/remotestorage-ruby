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
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Updated data"
      redirect_to :edit
    else
      flash[:error] = "Validation failed"
      render "edit"
    end
  end

  def dump_data
    send_data current_user.nodes.order('path ASC').inject({}) {|m, node|
      m.update(node.path => node.data)
    }.to_json, :type => 'application/json', :disposition => 'attachment', :filename => "#{current_user.login}-#{RemoteStorage::HOSTNAME}.json"
  end

end
