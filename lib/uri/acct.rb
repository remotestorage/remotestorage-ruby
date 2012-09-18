require 'uri'

module URI
  class ACCT < Generic
    include(::URI::REGEXP)

    DEFAULT_PORT = nil

    COMPONENT = [ :scheme, :user, :host ].freeze

    attr_reader :user

    def initialize(*arg)
      super(*arg)

      parts = @opaque.split('@')
      @user = parts[0]
      @host = parts[1]
    end
  end

  @@schemes['ACCT'] = ACCT
end
