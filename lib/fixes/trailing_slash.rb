module Fixes
  class TrailingSlash

    def initialize(app)
      @app = app
    end

    def call(env)
      env['TRAILING_SLASH'] = !!(env['PATH_INFO'] && env['PATH_INFO'] =~ /\/$/)
      @app.call(env)
    end

  end
end
