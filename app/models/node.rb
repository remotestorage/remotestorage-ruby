class Node < ActiveRecord::Base

  class << self

    def put(path, data, content_type)
      node = by_path(path)
      if node
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
  validates_presence_of :content_type

  validate :clean_path
  after_save :update_parent

  def parent
    return nil if path.empty?
    parent = user.nodes.where(:path => parent_path, :directory => true).first
    unless parent
      parent = user.nodes.new(:path => parent_path, :directory => true)
    end
    return parent
  end

  def children
    directory_listing.keys.map do |key|
      user.nodes.by_path([path, key].join('/'))
    end
  end

  def update_child!(child)
    listing = directory_listing
    child_parts = child.path.split('/')
    key = child_parts.last
    prefix = child_parts[0..-2].join('/')
    if prefix != self.path
      raise "invalid child: #{self.path.inspect} != #{prefix.inspect}"
    end
    listing[key] = child.updated_at.to_i
    update_directory(listing)
    save!
  end

  private

  def clean_path
    self.path = self.class.clean_path(self.path)
  end

  def update_parent
    if parent
      parent.update_child!(self)
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

  def update_directory(listing)
    self.content_type ||= 'application/json'
    self.data = JSON.dump(listing)
  end

end
