class User < ActiveRecord::Base

  acts_as_authentic

  has_many :authorizations
  has_many :nodes

  class << self
    def by_uri(uri)
      
    end
  end

end
