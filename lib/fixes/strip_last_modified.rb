module Fixes
  class StripLastModified

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers.delete('Last-Modified')
      return [status, headers, body]
    end

  end
end
