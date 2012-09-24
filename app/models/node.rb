class Node < ActiveRecord::Base

  class << self

    def put(path, data, content_type)
      node = by_path(path)
      if node && node.directory?
        # prevent PUT on directories (remoteStorage.js shouldn't send them anyway...)
        return
      elsif node
        node.update_attributes!(:data => data, :content_type => content_type)
      else
        create!(:path => path, :data => data, :directory => false, :content_type => content_type)
      end
    end

    def by_path(path)
      directory = !!(path =~ /\/$/)
      where(:path => clean_path(path), :directory => directory).first
    end

    def clean_path(path)
      path.split('/').reject(&:empty?).join('/')
    end
  end

  belongs_to :user

  validates_uniqueness_of :path
  validates_presence_of :content_type, :data

  validate :clean_path
  after_save :update_parent_on_save
  after_destroy :update_parent_on_destroy

  def parent
    return nil if path.empty?
    parent = user.nodes.where(:path => parent_path, :directory => true).first
    unless parent
      parent = user.nodes.new(:path => parent_path, :directory => true)
      parent.__send__ :ensure_directory_listing
      parent.save!
    end
    return parent
  end

  def children
    directory_listing.keys.map do |key|
      user.nodes.by_path([path, key].join('/'))
    end
  end

  def basename
    "#{path.split('/').last}#{directory? ? '/' : ''}"
  end

  def pathname
    path.split('/')[0..-2].join('/')
  end

  def update_child!(child, remove)
    listing = directory_listing
    key = child.basename
    prefix = child.pathname
    if prefix != self.path
      raise "invalid child: #{self.path.inspect} != #{prefix.inspect}"
    end
    if remove
      listing.delete(key)
    else
      listing[key] = child.updated_at.to_i
    end
    update_directory(listing)
    save!
  end

  def bytesize
    [path, data, content_type].map(&:bytesize).inject(:+)
  end

  private

  def clean_path
    self.path = self.class.clean_path(self.path)
  end

  def update_parent_on_save
    if parent
      parent.update_child!(self, false)
    end
  end

  def update_parent_on_destroy
    if parent
      parent.update_child!(self, true)
    end
  end

  def parent_path
    self.path.split('/')[0..-2].join('/')
  end

  def directory_listing
    raise "not a directory" unless directory?
    JSON.parse(self.data)
  rescue => exc
    {}
  end

  def ensure_directory_listing
    update_directory(directory_listing)
  end

  def update_directory(listing)
    self.content_type ||= 'application/json'
    self.data = JSON.dump(listing)
  end

end
