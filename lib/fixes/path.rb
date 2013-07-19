module Fixes
  class Path

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['PATH_INFO'] =~ /^\/storage\/[^\/]+\/(.*)$/
        env['DATA_PATH'] = $~[1].length > 0 ? $~[1].gsub(/(?:^|\/)\.\.(?:\/|$)/, '/')  : '/'
      end
      @app.call(env)
    end

  end
end
