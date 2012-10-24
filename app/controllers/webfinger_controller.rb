class WebfingerController < ApplicationController

  STORAGE_TYPE = 'https://www.w3.org/community/rww/wiki/read-write-web-00#simple'
  AUTH_METHOD = 'https://tools.ietf.org/html/draft-ietf-oauth-v2-26#section-4.2'

  before_filter :add_cors_headers

  def host_meta
    if params[:resource]
      uri = URI.parse(params[:resource])

      if uri.host == RemoteStorage::HOSTNAME && (@user = User.find_by_login(uri.user.downcase))
        render :json => {
          :links => [{
              :rel => 'remoteStorage',
              :href => node_url(:user => @user.login),
              :type => STORAGE_TYPE,
              :properties => {
                'auth-method' => AUTH_METHOD,
                'auth-endpoint' => new_authorization_url(:login => @user.login, :only_path => false)
              }
            }]
        }
      else
        render :status => 404, :text => 'Not found'
      end
    else
      render :json => {
        :links => [{
            :rel => 'lrdd',
            :template => webfinger_url(:only_path => false) + '?resource={uri}'
          }]
      }
    end
  end

end
