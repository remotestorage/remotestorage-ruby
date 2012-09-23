module ApplicationHelper

  def start_app_url(app)
    app.build_start_url(
      :storage_root => node_url(:user => current_user.login),
      :storage_api => WebfingerController::STORAGE_TYPE,
      :authorize_endpoint => new_authorization_url(:login => current_user.login)
    )
  end

end
