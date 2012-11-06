class NodesController < ApplicationController

  before_filter :fix_path
  before_filter :fetch_user
  before_filter :add_cors_headers
  before_filter :authorize

  def get
    @node = @user.nodes.by_path(params[:path])
    if @node
      headers['Last-Modified'] = (@node ? @node.updated_at : Time.now).utc.strftime('%a, %d %b %Y %T GMT')
      response['Content-Type'] = "#{@node.content_type}; charset=#{@node.binary ? 'binary' : 'UTF-8'}"
      render :text => @node.data
    elsif params[:path] =~ /\/$/
      # empty directory.
      response['Content-Type'] = 'application/json; charset=UTF-8'
      render :text => {}
    else
      not_found
    end
  end

  def put
    @user.nodes.put(params[:path], request.raw_post, request.content_type, binary?)
    render :text => ''
  end

  def delete
    @node = @user.nodes.by_path(params[:path])
    if @node && (! @node.directory?)
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
    if auth = get_auth_header
      auth.sub(/^Bearer\s+/, '')
    else
      ''
    end
  end

  def get_auth_header
    # no idea, but in some cases only one is set.
    request.env['HTTP_AUTHORIZATION'] || request.headers['Authorization']
  end

  def access_denied
    render :status => 401, :text => 'denied.'
  end

  def not_found
    render :status => 404, :text => ''
  end

  def fix_path
    params[:path] = request.env['DATA_PATH']
  end

  def binary?
    md = request.env['CONTENT_TYPE'].match(/charset=([^\s]+)/)
    return md ? md[1] == 'binary' : false
  end

end
