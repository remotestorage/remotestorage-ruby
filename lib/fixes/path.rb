module Fixes
  class Path
    TRAVERSAL_RE = /(?:^|\/)\.\.(?:\/|$)/

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'] =~ /^\/storage\/[^\/]+\/(.*)$/
        data_path = $~[1].length > 0 ? $~[1] : '/'
        while data_path.match TRAVERSAL_RE
          data_path.gsub! TRAVERSAL_RE, '/'
        end
        env['DATA_PATH'] = data_path
      end
      @app.call(env)
    end

  end
end
