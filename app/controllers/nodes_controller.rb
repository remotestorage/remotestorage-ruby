class NodesController < ApplicationController

  before_filter :fix_path
  before_filter :fetch_user
  before_filter :authorize

  before_filter :add_cors_headers

  def get
    @node = @user.nodes.by_path(params[:path])
    headers['Last-Modified'] = (@node ? @node.updated_at : Time.now).iso8601
    if @node
      render :text => @node.data, :content_type => @node.content_type
    elsif params[:path] =~ /\/$/
      # empty directory.
      render :json => {}
    else
      not_found
    end
  end

  def put
    @user.nodes.put(params[:path], request.raw_post, request.content_type)
    render :text => ''
  end

  def delete
    @node = @user.nodes.by_path(params[:path])
    unless @node.directory?
      @node.destroy
    end
    render :text => ''
  end

  private

  def fetch_user
    @user = User.find_by_login(params[:user])
    not_found unless @user
  end

  def authorize
    @authorization = @user.authorizations.find_by_token(get_bearer_token)
    path = params[:path]
    is_public = (path =~ /^public\//)
    is_directory = request.env['TRAILING_SLASH']
    mode = (params[:action] == 'get') ? :read : :write
    logger.info "Attempt authorization: is_public: #{is_public.inspect}, is_directory: #{is_directory.inspect}, mode: #{mode}, path: #{path}"
    if @authorization
      logger.info "Found authorization record, checking scope."
      if( @authorization.allows?(mode, path) ||
          (is_public && mode == :read) )
        logger.info "Authorized & allowed!"
        return
      else
        logger.info "Insufficient scope, denied!"
        access_denied
      end
    elsif (!is_directory) && is_public && mode == :read
      # FIXME: check if this is a directory listing!!!
      logger.info "Public & allowed!"
      return
    else
      logger.info "No authorization found, denied!"
      access_denied
    end
  end

  def get_bearer_token
    if auth = request.headers['Authorization']
      auth.sub(/^Bearer\s+/, '')
    else
      ''
    end
  end

  def access_denied
    render :status => 401, :text => 'denied.'
  end

  def not_found
    render :status => 404, :text => 'Not Found'
  end

  def fix_path
    # rails strips trailing slash.
    # https://github.com/rails/rails/issues/3215
    params[:path] = ((params[:path] || '') +
      (request.env['TRAILING_SLASH'] ? '/' : ''))
  end

end
