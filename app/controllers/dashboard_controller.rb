class DashboardController < ApplicationController

  before_filter :require_login

  def index
  end

  def data
    @nodes = current_user.nodes.order(:updated_at)
  end

end
