
require 'fileutils'
require 'ffi-xattr'

namespace :rs do

  task :repair_directories => :environment do
    User.all.each do |user|
      puts "User: #{user.login}"
      user.nodes.repair_directories
    end
  end

  desc "Export all data to the filesystem. Sets user.mime_type / user.charset extended attributes, so the data can be used by rs-serve. The directory to export to is specified by RS_EXPORT_DIR"
  task :export => :environment do
    export_root = ENV['RS_EXPORT_DIR']
    throw "RS_EXPORT_DIR not set!" unless export_root
    User.all.each do |user|
      puts "Starting to export #{user.login.inspect}"
      user_root = File.join export_root, user.login
      FileUtils.mkdir_p user_root
      user.nodes.where(:directory => false).in_groups_of(50) do |group|
        group.each do |node|
          next unless node
          node_path = File.join(user_root, node.path)
          rel_path = File.join(user.login, node.path)
          dir_path = File.dirname(node_path)
          unless File.directory? dir_path
            puts "MKDIR #{dir_path}"
            FileUtils.mkdir_p dir_path
          end
          puts "WRITE #{rel_path}"
          File.open node_path, 'w' do |f|
            f.write node.data
          end
          attrs = Xattr.new(node_path)
          attrs['user.mime_type'] = node.content_type
          attrs['user.charset'] = node.binary ? 'binary' : 'UTF-8'
        end
      end
    end
  end
end
