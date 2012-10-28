class Node < ActiveRecord::Base

  class << self

    def put(path, data, content_type)
      node = by_path(path)
      transaction do
        if node && node.directory?
          # prevent PUT on directories (remoteStorage.js shouldn't send them anyway...)
          return
        elsif node
          node.update_attributes!(:data => data, :content_type => content_type)
        else
          create!(:path => path, :data => data, :directory => false, :content_type => content_type)
        end
      end
    end

    def by_path(path)
      directory = !!(path =~ /\/$/)
      where(:path => clean_path(path), :directory => directory).first
    end

    def clean_path(path)
      path.split('/').reject(&:empty?).join('/')
    end

    def repair_directories
      transaction do
        where(:directory => true).each do |dir|
          puts "CLEAR #{dir.path}"
          dir.update_attributes!(:data => "{}")
        end
        where(["directory IS NULL OR directory = ?", false]) do |node|
          puts "SET #{node.path}"
          if node.parent
            node.parent.update_child!(self, false)
          end
        end
      end
    end
  end

  belongs_to :user

  validates_uniqueness_of :path, :scope => :user_id
  validates_presence_of :content_type

  validate :clean_path
  validate :data_or_binary_data
  after_save :update_parent_on_save
  after_destroy :update_parent_on_destroy

  def parent_path
    self.path.split('/')[0..-2].join('/') || ''
  end

  def parent
    retried = false
    return nil if path.empty?
    pp = parent_path
    parent = user.nodes.where(:path => pp, :directory => true).first
    unless parent
      parent = user.nodes.new(:path => pp, :directory => true)
      parent.__send__ :ensure_directory_listing
      logger.info("Saving parent: #{parent.path}")
      parent.save!
    end
    return parent
  rescue ActiveRecord::RecordInvalid => exc
    raise exc unless retried
    retried = true
    retry
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
      listing[key] = (child.updated_at.utc.to_f * 1000).round
    end
    if listing.keys.blank?
      destroy
    else
      update_directory(listing)
      save!
    end
  end

  def bytesize
    [path, data, content_type].map(&:bytesize).inject(:+)
  end


  ## postgres can't convert the 'data' column to binary for some reason.
  ## due to lack of interest in this problem at the moment, I'm using a
  ## separate column for non-utf8 data

  def data
    read_attribute(binary ? :binary_data : :data)
  end

  def data=(value)
    if value.encoding == 'UTF-8'
      self.binary = false
      write_attribute(:data, value)
    else
      self.binary = true
      write_attribute(:binary_data, value)
    end
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

  def data_or_binary_data
    errors.add(:data, :required) unless data or binary_data
  end

end
