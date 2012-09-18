module Fixes
  class TrailingSlash

    def initialize(app)
      @app = app
    end

    def call(env)
      env['TRAILING_SLASH'] = !!(env['PATH_INFO'] && env['PATH_INFO'] =~ /\/$/)
      Rails.logger.info("TRAILING #{env['TRAILING_SLASH'].inspect}, path #{env['PATH_INFO'].inspect}")
      @app.call(env)
    end

  end
end
