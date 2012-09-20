class User < ActiveRecord::Base

  acts_as_authentic

  has_many :authorizations
  has_many :nodes

  def quota_info
    "#{format_bytes(quota_used)} / #{format_bytes(quota_max)}"
  end

  def quota_max
    -1
  end

  def quota_used
    nodes.inject(0) {|m, node|
      m + node.bytesize
    }
  end

  def format_bytes(bytes)
    if bytes < 0
      'unlimited'
    elsif bytes < 2048
      "#{bytes} B"
    elsif bytes < 1024 * 2048
      "#{bytes / 1024.0} KiB"
    elsif bytes < 1024 * 1024 * 2048
      "#{bytes / 1024.0 / 1024.0} MiB"
    elsif bytes < 1024 * 1024 * 1024 * 2048
      "#{bytes / 1024.0 / 1024.0 / 1024.0} GiB"
    else
      "quite a lot"
    end
  end

end
